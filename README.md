# GitSetup

This repository will setup Git for shell warriors.
It includes setup of Posh-git, P4Merge, and several shortcuts.

## Step 1 - Installing Git

* Download Git from the following link:
 <https://git-for-windows.github.io/>
* Install it with the following parameters:
  * Check the following under 'Selected Components', and uncheck everything else unless needed
    * Git LFS
    * Associate .git* configuration files with the default text editor
    * Check daily for Git for Windows updates
    * Add a Git Bash Profile to Windows Terminal
  * Select your preferred option of the three editors
  * **It will be overridden when this tutorial is done**
  * **Adjusting your PATH environment**:
    * Git from the command line and also from 3rd-party software
  * **Choosing the SSH executable**:
    * Use bundled OpenSSH
  * **HTTPS transport backend**:
    * Use the OpenSSL library
  * **Configuring the line ending conversions**:
    * Checkout as-is, commit as-is
  * **Configuring the terminal emulator to use with Git Bash**:
    * Use Windows' default console window
  * **Choose the default behavior of `git pull`**
    * Fast-forward or merge
  * **Choose a credential helper**
    * Git Credential Manager
  * The check boxes under 'Configuring extra options' are optional

## Step 2 - Running the script

* Open PowerShell in **Administrator mode**:

* Replace the first two lines with your own data:

```powershell
$YourName = "Anon McAnon" #Replace this value
$YourEmail = "anon@mail.com" #Replace this value

$Folderpath = ".\GitSetup" #Current location in a folder called "GitSetup"

# Download data from he Git repository
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-RestMethod -Uri https://github.com/bakgaard/GitSetup/archive/master.zip -OutFile "$Folderpath.zip"

# Unzip the files
Expand-Archive "$Folderpath.zip" -DestinationPath $Folderpath -Force

cd "$Folderpath/GitSetup-master"

# Setup PowerShell for Git
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm -Force
./GitSetup $YourName $YourEmail

# Clean up .zip-file and extracted folder
cd "../.."
rm "$Folderpath.zip"
rmdir $Folderpath -Recurse -Force
```

### Step 3 - Fix mergetool error

You will most likely encounter a merge tool error, which might be because you are missing ``msvcr110.dll``.
Download and install the [Visual C++ Redistributable for Visual Studio 2013](https://www.microsoft.com/en-us/download/details.aspx?id=40784), or use Chocolatey to do it:

```powershell
choco install vcredist2013 -y
```

## Errors

This is not perfect, so you might encounter an error or two:

### Can't run .ps1-script

This happens, and I can't really find the root cause, but I have a work-around:

* Open ``GitSetup.ps1``
* Copy everything to a new document, and save it as ``setup.ps1``
* Run ``setup.ps1 "Your name" "Your email"``

## Git cheat sheet

| **Simple operations** | **Full command** | **Alias version** |
| :--- | :--- | :--- |
| Add all files to be tracked | ``git add -A`` | ``g add -A`` |
| Add all files and a message to your commit | ``git commit -am "Your message"`` | ``g cma "Your message"`` |
| Push your commits to the remote (Origin) | ``git push`` | ``g ps`` |
| Push a newly created branch | ``git push -u origin BranchName`` | ``g ps -u origin BranchName`` |
| Fetch (peak) the latest changes | ``git fetch`` | ``g ft`` |
| Pull the latest changes | ``git pull`` | ``g pl`` |
| Show the status as a one-liner | ``git status -s`` | ``g ss`` |
| | | |
| **Branches and merges** | **Full command** | **Alias version** |
| Create branch | ``git branch BranchName`` | ``g br BranchName`` |
| Checkout / switch branch | ``git checkout ExistingBranchName`` | ``g co ExistingBranchName`` |
| Create and checkout branch | ``git checkout -b NewBranchName`` | ``g co -b NewBranchName`` |
| Merge another branch into current branch | ``git merge --no-ff OtherBranchName`` | ``g mff OtherBranchName`` |
| Open the mergetool | ``git mergetool`` | ``g mt`` |
| See branch tree | ``git log --graph --pretty=format...`` | ``g lg`` |
| See remote branches | ``git branch -r`` | ``g br -r`` |
| Clean up deleted branches | ``git fetch -p`` | ``g ft -p`` |
| | | |
| **Undo operations** | **Full command** | **Alias version** |
| Remove all pending changes | ``git checkout .`` | ``g co .`` |
| Rollback everything to last commit | ``git reset --hard HEAD^`` |   |
| Rollback everything to a specific commit | ``git reset --hard CommitId`` |   |
| Hide all changes temporarily | ``git stash`` |   |
| Apply hidden changes | ``git stash pop`` |   |
| Remove all files in .gitignore | ``git clean -dfX`` | ``g if`` (short for "ignored files") |

These are all defined in ``~/.gitconfig``, and can be changed in there.
