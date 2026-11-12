#!/bin/bash
set -eu
umask 077

if ! command -v git >/dev/null 2>&1; then
  printf '%s\n' 'Git is required. Ask your instructor to check this computer.' >&2
  exit 1
fi

ensure_gh() {
  local tools_bin="$HOME/HAU-Activities/.tools/bin" os arch exe=gh asset_os
  case "$(uname -s)" in
    Darwin*) os=mac; asset_os=macOS ;;
    MINGW*|MSYS*|CYGWIN*) os=windows; asset_os=windows; exe=gh.exe ;;
    *) os=other ;;
  esac
  export PATH="$tools_bin:$PATH"
  if [[ $os == windows ]]; then
    # winget and the MSI install gh where an already-open Git Bash cannot see it yet.
    for dir in "/c/Program Files/GitHub CLI" "${LOCALAPPDATA:+$(cygpath -u "$LOCALAPPDATA")/Microsoft/WinGet/Links}" "${LOCALAPPDATA:+$(cygpath -u "$LOCALAPPDATA")/Programs/GitHub CLI}"; do
      [[ -n "$dir" && -x "$dir/gh.exe" ]] && export PATH="$PATH:$dir"
    done
  fi
  hash -r 2>/dev/null || true
  if command -v gh >/dev/null 2>&1; then
    return
  fi
  if [[ $os == other ]]; then
    printf '%s\n' 'GitHub CLI is required for automatic sign-in. Install it from https://cli.github.com/ or ask your instructor to prepare this computer.' >&2
    exit 1
  fi
  if ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1; then
    printf '%s\n' 'curl and unzip are required to download GitHub CLI. Ask your instructor to prepare this computer.' >&2
    exit 1
  fi
  case "$(uname -m)" in
    arm64|aarch64) arch=arm64 ;;
    *) arch=amd64 ;;
  esac
  # Read the version from the release redirect, not the API: a lab shares one
  # address, and the unauthenticated API allows only 60 requests an hour.
  latest=$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/cli/cli/releases/latest) || latest=""
  gh_version=${latest##*/v}
  if [[ -z "$latest" || -z "$gh_version" || "$gh_version" == "$latest" ]]; then
    printf '%s\n' 'Could not reach GitHub to download GitHub CLI. Check the internet connection and run the launcher again.' >&2
    exit 1
  fi
  download_dir=$(mktemp -d "${TMPDIR:-/tmp}/hau-gh.XXXXXX")
  gh_url="https://github.com/cli/cli/releases/download/v${gh_version}/gh_${gh_version}_${asset_os}_${arch}.zip"
  printf 'GitHub CLI is not installed. Downloading GitHub CLI %s (no admin rights needed)...\n' "$gh_version"
  if ! curl -fL --silent --show-error "$gh_url" -o "$download_dir/gh.zip"; then
    rm -rf -- "$download_dir"
    printf '%s\n' 'GitHub CLI download failed. Check the internet connection and run the launcher again.' >&2
    exit 1
  fi
  unzip -q "$download_dir/gh.zip" -d "$download_dir"
  gh_binary=$(find "$download_dir" -type f -path "*/bin/$exe" -print -quit)
  if [[ -z "$gh_binary" ]]; then
    rm -rf -- "$download_dir"
    printf '%s\n' 'The GitHub CLI download did not contain its executable.' >&2
    exit 1
  fi
  mkdir -p "$tools_bin"
  cp "$gh_binary" "$tools_bin/$exe"
  chmod 755 "$tools_bin/$exe"
  rm -rf -- "$download_dir"
  hash -r 2>/dev/null || true
  if ! command -v gh >/dev/null 2>&1; then
    printf '%s\n' 'GitHub CLI was downloaded but cannot run. Ask your instructor to check this computer.' >&2
    exit 1
  fi
  printf 'GitHub CLI is ready: %s\n' "$(gh --version | head -n 1)"
}

ensure_gh

if command -v code >/dev/null 2>&1; then
  vscode=$(command -v code)
elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
  vscode="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
elif [[ -n "${LOCALAPPDATA:-}" ]] && command -v cygpath >/dev/null 2>&1 &&
     [[ -x "$(cygpath -u "$LOCALAPPDATA")/Programs/Microsoft VS Code/bin/code" ]]; then
  vscode="$(cygpath -u "$LOCALAPPDATA")/Programs/Microsoft VS Code/bin/code"
else
  printf '%s\n' 'Visual Studio Code was not found. Ask your instructor to check this computer.' >&2
  exit 1
fi
export PATH="$(dirname "$vscode"):$PATH"

read -r -p 'Your GitHub username (for the folder name): ' username
if [[ ! "$username" =~ ^[A-Za-z0-9][A-Za-z0-9-]{0,38}$ ]]; then
  printf '%s\n' 'Enter your GitHub username without @ or a URL.' >&2
  exit 1
fi
read -r -p 'Your name for Git commits: ' author
read -r -p 'Your GitHub commit email (a GitHub noreply address also works): ' email
if [[ ! "$author" =~ [^[:space:]] || ! "$email" =~ ^[^[:space:]@]+@[^[:space:]@]+$ ]]; then
  printf '%s\n' 'Enter a name and a valid email for your commits.' >&2
  exit 1
fi

work_root="$HOME/HAU-Activities"
mkdir -p "$work_root"
workspace=$(mktemp -d "$work_root/$username.XXXXXX")
profile=$(mktemp -d "${TMPDIR:-/tmp}/hau-activity-vscode.XXXXXX")
gh_config=$(mktemp -d "${TMPDIR:-/tmp}/hau-activity-gh.XXXXXX")

cleanup() {
  rm -rf -- "$gh_config"
}
trap cleanup EXIT

export GH_CONFIG_DIR="$gh_config"
printf '\nSign in to GitHub in the browser that opens. Use the same account as the username you entered.\n'
if ! gh auth status >/dev/null 2>&1; then
  gh auth login --hostname github.com --git-protocol https --web
fi
github_account=$(gh api user --jq '.login')
normalized_username=$(printf '%s' "$username" | tr '[:upper:]' '[:lower:]')
normalized_account=$(printf '%s' "$github_account" | tr '[:upper:]' '[:lower:]')
if [[ "$normalized_account" != "$normalized_username" ]]; then
  printf 'The signed-in GitHub account is %s, but you entered %s. Sign out in the browser and rerun the launcher.\n' "$github_account" "$username" >&2
  exit 1
fi

unset GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_ASKPASS SSH_ASKPASS GH_TOKEN GITHUB_TOKEN
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR VSCODE_IPC_HOOK_CLI
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
case "$(uname -s)" in
  MINGW*|MSYS*) export GIT_CONFIG_GLOBAL=NUL ;;
esac
unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL EMAIL
export GIT_CONFIG_KEY_0=credential.helper GIT_CONFIG_VALUE_0=
export GIT_CONFIG_KEY_1=credential.helper GIT_CONFIG_VALUE_1='!gh auth git-credential'
export GIT_CONFIG_KEY_2=user.name GIT_CONFIG_VALUE_2="$author"
export GIT_CONFIG_KEY_3=user.email GIT_CONFIG_VALUE_3="$email"
export GIT_CONFIG_KEY_4=credential.https://github.com.username GIT_CONFIG_VALUE_4="$username"
export GIT_CONFIG_COUNT=5

printf '\nWork folder: %s\n' "$workspace"
printf '%s\n' 'In the terminal that opens, run this command with your own private repository URL:' \
  'git clone https://github.com/ORG/ACTIVITY-CLASSCODE-USERNAME.git' \
  'Then enter the cloned folder with: cd ACTIVITY-CLASSCODE-USERNAME' \
  'Run code . to open that folder in this VS Code window.' \
  'GitHub is already signed in for this launch. Never enter a GitHub password or token into Git.' \
  'Use VS Code Source Control to commit and push. Check the commit on GitHub.' \
  'When finished, close VS Code and type exit in the launcher terminal. The temporary GitHub credential is then removed.'

cd "$workspace"
"$vscode" --new-window --user-data-dir "$profile" "$workspace"
printf '\nThis terminal is already in your work folder. After cloning, enter the cloned repo with cd.\n'
printf '%s\n' 'Use VS Code Source Control to commit and push. Type exit here when finished; the temporary GitHub credential is then removed.'
"${BASH}" --noprofile --norc -i
