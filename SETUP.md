# Set up your M2A1 activity

You need Git, Visual Studio Code and an internet connection. Install Dart 3.11.5 or newer within Dart 3. The launcher downloads a private copy of GitHub CLI when it is missing, with no admin rights needed.

## Create your private activity repo

Accept the invitation to [HAU-6ADET](https://github.com/HAU-6ADET). If the instructor already gave you an activity repo, use it. Otherwise, choose **Use this template → Create a new repository** on the starter, set the owner to **HAU-6ADET**, and choose **Private**.

Name your repo `m2a1-CLASSCODE-USERNAME`. Replace CLASSCODE with the numeric class code shown in your Canvas course and USERNAME with your GitHub username. The required prefix is `m2a1-CLASSCODE-` with your actual class code. Use your activity repo for the code and your separate student workspace for notes.

## Download and start the launcher

Use the launcher for your computer. Each one downloads GitHub CLI if needed, with no admin rights.

**Mac:** open **Terminal**, paste this command and press Enter.

```bash
cd ~ && curl -fsSLO https://raw.githubusercontent.com/HAU-6ADET/m2a1-classcode-yourname/main/start-activity-mac.sh && bash start-activity-mac.sh
```

**Windows:** open **Windows PowerShell** from the Start menu (not Git Bash or Command Prompt), paste this command and press Enter.

```powershell
irm https://raw.githubusercontent.com/HAU-6ADET/m2a1-classcode-yourname/main/start-activity-windows.ps1 | iex
```

Enter your GitHub username, name and GitHub commit email when asked. The launcher opens a fresh VS Code profile and leaves a terminal prompt in the new work folder. It downloads GitHub CLI if needed, opens the GitHub browser sign-in, checks that the signed-in account matches the username you entered, and gives Git a temporary credential helper for this launch. Do not type a GitHub password or token into Git.

## Clone and check your Git setup

1. On GitHub, open your **private activity repo**. Click **Code → HTTPS** and copy the clone URL.
2. In the terminal or PowerShell window the launcher left open, type each command below on its own line and press Enter after each one. Replace the URL with your own copied URL.

```bash
git clone https://github.com/HAU-6ADET/m2a1-CLASSCODE-USERNAME.git
```

3. Move into the folder the clone just made. It has the same name as your repo:

```bash
cd m2a1-CLASSCODE-USERNAME
```

Check that the prompt now ends with that folder name. Every command from here on runs inside it. Then open it in VS Code:

```bash
code .
```

GitHub is already authenticated by the launcher. If a Git prompt asks for a password or token, cancel it and rerun the launcher.

4. Still inside the cloned folder, run these three checks one at a time. Windows PowerShell does not accept `&&`, so do not join them into one line.

```bash
git status --short --branch
git remote -v
git var GIT_AUTHOR_IDENT
```

The first line should show your branch. The fetch and push URLs should point to your private repo in **HAU-6ADET**. The last line should show your own name and commit email. If it shows someone else's details, return to the launcher terminal or the new VS Code window and check again. These commands check local wiring. A successful VS Code clone confirms read access, and a successful push confirms write access.

Use VS Code **Source Control** to commit and push on the lab computer. Check your new commit on GitHub before submitting its URL. At the end of class, close the VS Code window, type `exit` in the launcher terminal or PowerShell window so its temporary credential is removed, and sign out of GitHub in the browser. Your local files remain in the work folder.

Continue with the [activity instructions](README.md).
