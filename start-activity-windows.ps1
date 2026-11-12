# HAU shared-lab launcher for Windows. Run it in PowerShell (not Git Bash):
#   irm https://raw.githubusercontent.com/ORG/ACTIVITY-classcode-yourname/main/start-activity-windows.ps1 | iex
# It downloads GitHub CLI if needed (no admin rights), signs you in to GitHub in the
# browser for this launch only, sets your Git name and email for this launch only,
# opens a fresh VS Code window and leaves a PowerShell prompt in a new work folder.
& {
  $ErrorActionPreference = 'Stop'
  function Fail($message) { Write-Host $message -ForegroundColor Red; throw 'Launcher stopped.' }

  # Git for Windows
  $git = Get-Command git.exe -ErrorAction SilentlyContinue
  if (-not $git) {
    foreach ($dir in @("$env:ProgramFiles\Git\cmd", "$env:LOCALAPPDATA\Programs\Git\cmd")) {
      if (Test-Path "$dir\git.exe") { $env:Path = "$dir;$env:Path"; $git = Get-Command git.exe; break }
    }
  }
  if (-not $git) { Fail 'Git is required. Ask your instructor to check this computer.' }

  # GitHub CLI: use an installed copy, else download the official zip into the user folder.
  $toolsBin = Join-Path $HOME 'HAU-Activities\.tools\bin'
  $env:Path = "$toolsBin;$env:Path"
  foreach ($dir in @("$env:ProgramFiles\GitHub CLI", "$env:LOCALAPPDATA\Microsoft\WinGet\Links", "$env:LOCALAPPDATA\Programs\GitHub CLI")) {
    if (Test-Path "$dir\gh.exe") { $env:Path = "$env:Path;$dir" }
  }
  $gh = Get-Command gh.exe -ErrorAction SilentlyContinue
  if (-not $gh) {
    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) { Fail 'curl.exe is missing. Ask your instructor to check this computer.' }
    # The release redirect names the version without the rate-limited API.
    $latest = & curl.exe -fsSLI -o NUL -w '%{url_effective}' 'https://github.com/cli/cli/releases/latest'
    if ($LASTEXITCODE -ne 0 -or $latest -notmatch '/v([0-9][^/]*)$') { Fail 'Could not reach GitHub to download GitHub CLI. Check the internet connection and run the launcher again.' }
    $version = $Matches[1]
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'arm64' } else { 'amd64' }
    $tmp = Join-Path $env:TEMP ("hau-gh-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tmp | Out-Null
    Write-Host "GitHub CLI is not installed. Downloading GitHub CLI $version (no admin rights needed)..."
    & curl.exe -fL --silent --show-error -o "$tmp\gh.zip" "https://github.com/cli/cli/releases/download/v$version/gh_${version}_windows_$arch.zip"
    if ($LASTEXITCODE -ne 0) { Remove-Item -Recurse -Force $tmp; Fail 'GitHub CLI download failed. Check the internet connection and run the launcher again.' }
    Expand-Archive -Path "$tmp\gh.zip" -DestinationPath $tmp -Force
    $exe = Get-ChildItem -Path $tmp -Recurse -Filter gh.exe | Select-Object -First 1
    if (-not $exe) { Remove-Item -Recurse -Force $tmp; Fail 'The GitHub CLI download did not contain gh.exe.' }
    New-Item -ItemType Directory -Force -Path $toolsBin | Out-Null
    Copy-Item $exe.FullName (Join-Path $toolsBin 'gh.exe') -Force
    Remove-Item -Recurse -Force $tmp
    $gh = Get-Command gh.exe -ErrorAction SilentlyContinue
    if (-not $gh) { Fail 'GitHub CLI was downloaded but cannot run. Ask your instructor to check this computer.' }
    Write-Host ("GitHub CLI is ready: " + ((& $gh.Source --version) | Select-Object -First 1))
  }
  $ghPath = $gh.Source

  # Visual Studio Code
  $code = Get-Command code.cmd -ErrorAction SilentlyContinue
  if ($code) { $code = $code.Source } else {
    $code = @("$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd", "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd") | Where-Object { Test-Path $_ } | Select-Object -First 1
  }
  if (-not $code) { Fail 'Visual Studio Code was not found. Ask your instructor to check this computer.' }

  $username = (Read-Host 'Your GitHub username (for the folder name)').Trim()
  if ($username -notmatch '^[A-Za-z0-9][A-Za-z0-9-]{0,38}$') { Fail 'Enter your GitHub username without @ or a URL.' }
  $author = (Read-Host 'Your name for Git commits').Trim()
  $email = (Read-Host 'Your GitHub commit email (a GitHub noreply address also works)').Trim()
  if (-not $author -or $email -notmatch '^[^\s@]+@[^\s@]+$') { Fail 'Enter a name and a valid email for your commits.' }

  $suffix = [guid]::NewGuid().ToString('N').Substring(0, 6)
  $workspace = Join-Path $HOME "HAU-Activities\$username.$suffix"
  $profileDir = Join-Path $env:TEMP "hau-activity-vscode-$suffix"
  $ghConfig = Join-Path $env:TEMP "hau-activity-gh-$suffix"
  New-Item -ItemType Directory -Force -Path $workspace, $profileDir, $ghConfig | Out-Null

  $names = 'GH_CONFIG_DIR','GIT_CONFIG_GLOBAL','GIT_CONFIG_NOSYSTEM','GIT_CONFIG_COUNT','GIT_CONFIG_KEY_0','GIT_CONFIG_VALUE_0','GIT_CONFIG_KEY_1','GIT_CONFIG_VALUE_1','GIT_CONFIG_KEY_2','GIT_CONFIG_VALUE_2','GIT_CONFIG_KEY_3','GIT_CONFIG_VALUE_3','GIT_CONFIG_KEY_4','GIT_CONFIG_VALUE_4'
  try {
    foreach ($n in 'GIT_CONFIG_PARAMETERS','GIT_CONFIG_SYSTEM','GIT_ASKPASS','SSH_ASKPASS','GH_TOKEN','GITHUB_TOKEN','GIT_DIR','GIT_WORK_TREE','GIT_AUTHOR_NAME','GIT_AUTHOR_EMAIL','GIT_COMMITTER_NAME','GIT_COMMITTER_EMAIL') { Remove-Item "Env:$n" -ErrorAction SilentlyContinue }
    $env:GH_CONFIG_DIR = $ghConfig
    Write-Host "`nSign in to GitHub in the browser that opens. Use the same account as the username you entered."
    & $ghPath auth login --hostname github.com --git-protocol https --web
    if ($LASTEXITCODE -ne 0) { Fail 'GitHub sign-in did not finish. Run the launcher again.' }
    $account = (& $ghPath api user --jq '.login').Trim()
    if ($account.ToLower() -ne $username.ToLower()) { Fail "The signed-in GitHub account is $account, but you entered $username. Sign out in the browser and run the launcher again." }

    $helper = '!"' + ($ghPath -replace '\\','/') + '" auth git-credential'
    $env:GIT_CONFIG_GLOBAL = 'NUL'; $env:GIT_CONFIG_NOSYSTEM = '1'; $env:GIT_CONFIG_COUNT = '5'
    $env:GIT_CONFIG_KEY_0 = 'credential.helper'; $env:GIT_CONFIG_VALUE_0 = ''
    $env:GIT_CONFIG_KEY_1 = 'credential.helper'; $env:GIT_CONFIG_VALUE_1 = $helper
    $env:GIT_CONFIG_KEY_2 = 'user.name'; $env:GIT_CONFIG_VALUE_2 = $author
    $env:GIT_CONFIG_KEY_3 = 'user.email'; $env:GIT_CONFIG_VALUE_3 = $email
    $env:GIT_CONFIG_KEY_4 = 'credential.https://github.com.username'; $env:GIT_CONFIG_VALUE_4 = $username

    Write-Host "`nWork folder: $workspace"
    Write-Host 'In this window, run this command with your own private repository URL:'
    Write-Host '  git clone https://github.com/ORG/ACTIVITY-CLASSCODE-USERNAME.git'
    Write-Host 'Then enter the cloned folder with: cd ACTIVITY-CLASSCODE-USERNAME'
    Write-Host 'Run code . to open that folder in the new VS Code window.'
    Write-Host 'GitHub is already signed in for this launch. Never enter a GitHub password or token into Git.'
    Write-Host 'Use VS Code Source Control to commit and push. Check the commit on GitHub.'
    Write-Host 'When finished, close VS Code and type exit here. The temporary GitHub credential is then removed.'

    & $code --new-window --user-data-dir $profileDir $workspace
    Push-Location $workspace
    try { & powershell.exe -NoLogo -NoExit -NoProfile -ExecutionPolicy Bypass -Command "Set-Location -LiteralPath '$workspace'; function global:prompt { 'HAU ' + (Get-Location) + '> ' }" }
    finally { Pop-Location }
  } finally {
    foreach ($n in $names) { Remove-Item "Env:$n" -ErrorAction SilentlyContinue }
    Remove-Item -Recurse -Force $ghConfig -ErrorAction SilentlyContinue
    Write-Host 'Launcher closed. The temporary GitHub credential was removed; your files stay in the work folder.'
  }
}
