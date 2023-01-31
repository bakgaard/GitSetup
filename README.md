# GitSetup
This repository will setup Git for shell warriors. 
It includes setup of Posh-git, P4Merge, and several shortcuts.


## Step 1 - Installing Git:
* Download Git from the following link:
	https://git-for-windows.github.io/
* Install it with the following parameters:
	* Check the following under 'Selected Components', and uncheck everything else unless needed
		* Git LFS
		* Use a TrueType font in all console windows
	* Select your preferred option of the three editors
		* **It will be overridden when this tutorial is done**
	* Select the following radio button under 'Adjusting your PATH environment'
		* Use Git from the Windows Command Prompt
	* Select the following radio button under 'HTTPS transport backend'
		* Use the OpenSSL library
	* Select the following radio button under 'Configuring the line ending conversions'
		* Checkout as-is, commit as-is
	* Select the following radio button under 'Configuring the terminal emulator to use with Git Bash'
		* Use Windows' default console window
	* The check boxes under 'Configuring extra options' are optional


## Step 2 - Running the script:

* Open PowerShell in **Administrator mode**:

* Replace the first two lines with your own data:

```powershell
$YourName = "Anon McAnon" #Replace this value
$YourEmail = "anon@mail.com" #Replace this value
$Folderpath = ".\GitSetup" #Current location in a folder called "GitSetup"

# Download data from he Git repository
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -URI https://github.com/bakgaard/GitSetup/archive/master.zip -OutFile "$Folderpath.zip"

# Unzip the files
Expand-Archive "$Folderpath.zip" -DestinationPath $Folderpath -Force

cd "$Folderpath/GitSetup-master"

# Setup PowerShell for Git
Set-ExecutionPolicy RemoteSigned -Scope Process -Confirm -Force
./GitSetup $YourName $YourEmail

# Clean up .zip-file and extracted folder
cd "../.."
rm "$Folderpath.zip"
rmdir $Folderpath -Recurse -Force
```


### Step 3 - Mergetool error

You will most likely encounter a merge tool error, which might be because you are missing ``msvcr110.dll``.
Download and install the [Visual C++ Redistributable for Visual Studio 2012 Update 4](https://www.microsoft.com/en-us/download/confirmation.aspx?id=30679), or use Chocolatey to do it:

```powershell
choco install vcredist2012
```



## Optional

* Change editor when making ``--amend`` messages using the alias ``git sublime`` and ``git notepad``.

  Make sure the path in ``~/.gitconfig``'s line 34 and 35 are correct, or add your own favorite editor to it.




## Errors

This is not perfect, so you might encounter an error or two:


### Can't run .ps1-script

This happens, and I can't really find the root cause, but I have a work-around:

* Open ``GitSetup.ps1``
* Copy everything to a new document, and save it as ``setup.ps1``
* Run ``setup.ps1 "Your name" "Your email"``


### It ask if I have installed Sublime Text 3

When installing Git, it will ask you which editor you prefer, and save that in your ``~/.gitconfig``.
This is overwritten in Step 2, so you have to do something to switch to, for example, Notepad++.

I have implemented an alias to switch to Notepad++ which you can run as so:
```powershell
git notepad #Will switch to Notepad++ (x64 folder)
git sublime #Will switch to Sublime Text 3
```

If you use something else, have a look inside the ``~/.gitconfig`` file, and go to the ``[core]`` section.
Here you can specify which editor to start up in the ``editor`` line.


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
| | |
| **Branches and merges** | **Full command** | **Alias version** |
| Create branch | ``git branch BranchName`` | ``g br BranchName`` |
| Checkout / switch branch | ``git checkout ExistingBranchName`` | ``g co ExistingBranchName`` |
| Create and checkout branch | ``git checkout -b NewBranchName`` | ``g co -b NewBranchName`` |
| Merge another branch into current branch | ``git merge --no-ff OtherBranchName`` | ``g mff OtherBranchName`` |
| Open the mergetool | ``git mergetool`` | ``g mt`` |
| See branch tree | ``git log --graph --pretty=format...`` | ``g lg`` |
| See remote branches | ``git branch -r`` | ``g br -r`` |
| Clean up deleted branches | ``git fetch -p`` | ``g ft -p`` |
| | |
| **Undo operations** | **Full command** | **Alias version** |
| Remove all pending changes | ``git checkout .`` | ``g co .`` |
| Rollback everything to last commit | ``git reset --hard HEAD^`` |   |
| Rollback everything to a specific commit | ``git reset --hard CommitId`` |   |
| Hide all changes temporarily | ``git stash`` |   |
| Apply hidden changes | ``git stash pop`` |   |
| Remove all files in .gitignore | ``git clean -dfX`` | ``g if`` (short for "ignored files") |

These are all defined in ``~/.gitconfig``, and can be changed in there.
