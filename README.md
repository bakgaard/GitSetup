# GitSetup
This repository will setup Git for shell warriors. It includes setup of Posh-git, P4Merge, and several shortcuts

* Add a PowerShell profile, if you do not have one. This gives you the shortcut ``g`` for ``git``.
* Tell PowerShell where Git is located, so the commands can be used
* Override the ``~/.gitconfig`` file with a whole lot of new aliases, and set it up to default use P4Merge. Open ``~/.gitconfig`` in your favorite editor (note MS Notepad) to see all of these.
* Install a light version of P4Merge 2015.2
* Install [Posh-gi](https://github.com/dahlbyk/posh-git) for better overview of Git in PowerShell
* Setup a proxy for Git, extracting the data from Internet Explorer (should there be any)
* Setup an SSH-key, which is located under ``~/.ssh/id_rsa.pub`` (use to authorize you with TFS/GitHub/BitBucket/TeamCity/Jenkins/GitLab/...)


## Step 1 - Installing Git:
* Download Git from the following link:
	https://git-for-windows.github.io/
* Install it with the following parameters:
	* Check the following under 'Selected Components', and uncheck everything else unless needed
		* Git LFS
		* Use a TrueType font in all console windows
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

Running the GitSetup.ps1-file will setup the following for you

(While in Administrator mode)
* ``cd`` to this folder
	* Can be accomplished by typing 'Powershell' in the folder path in the top of the explorer

* Run the following command including the quotation marks, but with your name and email:

	 ``./GitSetup "Your name" "Your email"``



## Optional

* If your favorite editor is not Sublime Text 3, you can open your ``~/.gitconfig``, go to the section "core", and use another path for the ``editor``.
  An example for use of Notepad++ can be seen on line 36

