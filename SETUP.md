# Set up your M2A1 activity

You need Git, Visual Studio Code and an internet connection. Install Dart 3.11.5 or newer within Dart 3. The launcher downloads a private copy of GitHub CLI on macOS when it is missing. On Windows it uses `winget` when available.

## Create your private activity repo

Accept the invitation to [HAU-6ADET](https://github.com/HAU-6ADET). If the instructor already gave you an activity repo, use it. Otherwise, choose **Use this template → Create a new repository** on the starter, set the owner to **HAU-6ADET**, and choose **Private**.

Name your repo `m2a1-CLASSCODE-USERNAME`. Replace CLASSCODE with the numeric class code shown in your Canvas course and USERNAME with your GitHub username. The required prefix is `m2a1-CLASSCODE-` with your actual class code. Use your activity repo for the code and your separate student workspace for notes.

## Download and start the launcher

**Download [start-activity.sh](start-activity.sh) before cloning.** Open the file on the GitHub template, click **Download raw file**, and save it in Downloads as `start-activity.sh`. On Mac, open **Terminal**. On Windows, open **Git Bash** from Git for Windows. Run these commands from that standalone terminal.

```bash
cd "$HOME/Downloads"
bash ./start-activity.sh
```

If you saved it elsewhere, change into that folder first. Enter your GitHub username, name and GitHub commit email when asked. The launcher opens a fresh VS Code profile and leaves a terminal prompt in the new work folder. It downloads GitHub CLI if needed, opens the GitHub browser sign-in, checks that the signed-in account matches the username you entered, and gives Git a temporary credential helper for this launch. Do not type a GitHub password or token into Git.

## Clone and check your Git setup

1. On GitHub, open your **private activity repo**. Click **Code → HTTPS** and copy the clone URL.
2. In the terminal opened by the launcher, run the clone command. Replace the URL with your own copied URL.

```bash
git clone https://github.com/HAU-6ADET/m2a1-CLASSCODE-USERNAME.git
cd m2a1-CLASSCODE-USERNAME
code .
```

GitHub is already authenticated by the launcher. If a Git prompt asks for a password or token, cancel it and rerun the launcher.
3. In the terminal inside the cloned folder, paste this check.

```bash
git status --short --branch && git remote -v && git var GIT_AUTHOR_IDENT
```

The first line should show your branch. The fetch and push URLs should point to your private repo in **HAU-6ADET**. The last line should show your own name and commit email. If it shows someone else's details, return to the launcher terminal or the new VS Code window and check again. The command checks local wiring. A successful VS Code clone confirms read access, and a successful push confirms write access.

Use VS Code **Source Control** to commit and push on the lab computer. Check your new commit on GitHub before submitting its URL. At the end of class, close the VS Code window, type `exit` in the launcher terminal so its temporary credential is removed, and sign out of GitHub in the browser. Your local files remain in the work folder.

Continue with the [activity instructions](README.md).
