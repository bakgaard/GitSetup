# GitSetup
This repository will setup Git for shell warriors. It includes setup of Posh-git, P4Merge, and several shortcuts

* Add a PowerShell profile, if you do not have one. This gives you the shortcut ``g`` for ``git``.
* Tell PowerShell where Git is located, so the commands can be used
* Override the ``~/.gitconfig`` file with a whole lot of new aliases, and set it up to default use P4Merge. Open ``~/.gitconfig`` in your favorite editor to see all of these.
* Install a light version of P4Merge 2015.2
* Install [Posh-git](https://github.com/dahlbyk/posh-git) for better overview of Git in PowerShell
* Setup a proxy for Git, extracting the data from Internet Explorer (should there be any)
* Setup an SSH-key, which is located under ``~/.ssh/id_rsa.pub`` (use to authorize you with TFS/GitHub/BitBucket/TeamCity/Jenkins/GitLab/...)


## Step 1 - Installing Git:
* Download Git from the following link:
	https://git-for-windows.github.io/
* Install it with the following parameters:
	* Check the following under 'Selected Components', and uncheck everything else unless needed
		* Git LFS
		* Use a TrueType font in all console windows
	* Select your prefered option of the three editors
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

Open PowerShell in **Administrator mode**:

* Replace the first two lines with your own data:

```powershell
$YourName = "Anon McAnon" #Replace this value
$YourEmail = "anon@mail.com" #Replace this value
$Folderpath = ".\GitSetup" #Current location in a folder called "GitSetup"

# Download data from he Git repository
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Import-Module BitsTransfer
Start-BitsTransfer -Source https://github.com/bakgaard/GitSetup/archive/master.zip -Destination "$Folderpath.zip"

# Unzip the files
Expand-Archive "$Folderpath.zip" -DestinationPath $Folderpath -Force

cd "$Folderpath/GitSetup-master"

# Setup PowerShell for Git
Set-ExecutionPolicy RemoteSigned -Scope Process -Confirm -Force
./GitSetup $YourName $YourEmail
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



### Mergetool error

If you encounter a merge tool error, it might be because you are missing ``msvcr110.dll``.
Download and install the [Visual C++ Redistributable for Visual Studio 2012 Update 4](https://www.microsoft.com/en-us/download/confirmation.aspx?id=30679), or use Chocolatey to do it:

```powershell
choco install vcredist2012
```
