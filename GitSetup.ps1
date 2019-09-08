#Run the following command with quotations:
# ./GitSetup "Your name" "Your email"

param(
	[Parameter(Mandatory=$true)] [string]$name, 
	[Parameter(Mandatory=$true)] [string]$mail
)

$ErrorActionPreference = "Stop"

$global:x86 = $true
$global:PowerProfile = $PROFILE
$global:ConfigFile = ".gitconfig"
$global:P4MergeFile = "P4Merge.zip"
$global:gitPath = "${env:ProgramFiles(x86)}" + "\Git"
$global:mergePath = $gitPath + "\libexec\git-core\mergetools"
$global:installationFolder = $pwd;

function CheckAdminMode
{
	$IsInAdminMode = ([Security.Principal.WindowsPrincipal] `
	[Security.Principal.WindowsIdentity]::GetCurrent() `
	).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

	if($IsInAdminMode -eq $False) {
		Write-Error "You are not in admin mode! Please switch to run this installtion script."
	}
}

function CheckPowerShellVersion
{
	if($PSVersionTable.PSVersion.Major -ne 5) {
		Write-Host "You are not running PowerShell version 5+, and cannot make a full installation (Post-git requires it)." -Foreground Red
		Write-Host "To upgrade, you can install Chocolatey through the following command, followed by a restart:" -Foreground Cyan
		Write-Host "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" -Foreground Gray
		Write-Host "After that, run the following code to install the new verison of PowerShell:"
		Write-Host "choco install powershell -y" -Foreground Gray
		Write-Error "You are not running PowerShell version 5+! Please upgrade."
	}

	Install-PackageProvider NuGet -Force
	Import-PackageProvider NuGet -Force
}

function CheckIfMsysIsInstallad
{
	# Check if MSysGit has been installed
	$ValidPath = Test-Path $gitPath
	if($ValidPath -eq $false)
	{
		$global:x86 = $false
		$global:gitPath = "${env:ProgramFiles}" + "\Git"
		$global:mergePath = $gitPath + "\mingw64\libexec\git-core\mergetools"
	}

	$ValidPath = Test-Path $global:gitPath
	# It has not:
	if ($ValidPath -eq $false) 
	{
		Write-Host "You have not install MSysGit yet. Please do so." -Foreground Green
		Write-Host "Please hit a key to download it..." -Foreground Green
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

		# Open browser to GitHub to insert key
		cmd.exe /C start https://git-for-windows.github.io/

		$host.exit
	}
}

# Test if .$PROFILE has been created.
# If not, do so
function CreateProfile
{
	# Check if the profile has been created
	$GotPath = Test-path $global:PowerProfile

	# Create profile
	if(-not $GotPath) 
	{
		New-item -type file -force $global:PowerProfile
	}	
}

# Download prefix for the profile as either x64 or x86 
function DownloadGit
{
	#Paste to $PROFILE
	if($global:x86 -eq $true)
	{
		$text = @"
`$env:path += ";" + (Get-Item "Env:ProgramFiles").Value + "\Git\bin"
`$env:path += ";" + (Get-Item "Env:ProgramFiles").Value + "\Git\cmd"
`$env:home = `$env:userprofile

#Alias
Set-Alias g git        # Use Git commands but just typing 'g'
Set-Alias ex explorer  # Open a File Explorer with 'ex .'

Import-Module posh-sshell
Start-Service ssh-agent
"@

		$text | out-file $global:PowerProfile
	}
	else #x64
	{
		$text = @"
`$env:path += ";" + (Get-Item "Env:ProgramFiles").Value + "\Git\bin"
`$env:path += ";" + (Get-Item "Env:ProgramFiles").Value + "\Git\cmd"
`$env:path += ";" + (Get-Item "Env:ProgramFiles").Value + "\Git\usr\bin"
`$env:home = `$env:userprofile
 
#Alias
Set-Alias g git        # Use Git commands but just typing 'g'
Set-Alias ex explorer  # Open a File Explorer with 'ex .'
"@

		$text | out-file $global:PowerProfile
	}
}


function SetupSSH
{
	try 
	{
		# Generate an ssh-key to use
		Write-Host "If you want a password enter one. Else leave blank" -Foreground Green

		$sshPath = (Get-Item "Env:userprofile").Value + "\.ssh"
		$sshKey = $sshPath + "\id_rsa"

		if((Test-Path $sshPath) -eq $false)
		{
			New-item $sshPath -itemType directory
			Set-itemProperty -Path $sshPath -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)
		}
		ssh-keygen.exe -f $sshKey		
	}
	catch
	{
		Write-Host "Something went wrong when you tried to setup your SSH-key"
	}
}

#Download content for the ~/.gitconfig file
function DownloadGitconfigContent
{
	try
	{
		# Download content and paste to .gitconfig
		Write-Host "Overriding the .gitconfig file. It can be found in $env:userprofile\$global:ConfigFile"
		cp "$global:installationFolder\gitconfig.txt" "$env:userprofile\$global:ConfigFile"
		
		# Insert your name and email into .gitconfig
		git config --global user.name "$name"
		git config --global user.email "$mail"
	}
	catch {
		Write-Host "Can't use Git - No clue to why this is happening"
	}
}

function SetupMergeTool
{
	try
	{
		# Extract it
		Write-Host "Installing P4Merge as mergetool"
		$shell = new-object -com shell.application
		$zip = $shell.NameSpace("$pwd\$global:P4MergeFile")
		foreach($item in $zip.items())
		{
			$shell.Namespace($mergePath).copyhere($item, 0x14)
		}

		# Insert start menu link
		$objShell = New-Object -ComObject ("WScript.Shell")
		$objShortCut = $objShell.CreateShortcut($env:ALLUSERSPROFILE + "\Microsoft\Windows\Start Menu\Programs" + "\P4Merge.lnk")
		$objShortCut.TargetPath = "C:\Program Files\Git\mingw64\libexec\git-core\mergetools\p4merge.exe"
		$objShortCut.Save()
	}
	catch	{
		Write-Host "Are you sure you are in Admin mode?" -ForegroundColor Green
	}
}
	
#If needed - Posh-git cannot be downloaded without
function SetupProxy
{
	# Set proxy, if any
	$proxies = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').proxyServer

	if ($proxies)
	{
		if ($proxies -ilike "*=*")
		{
			$proxies -replace "=","://" -split(';') | Select-Object -First 1
		}

		else
		{
			"http://" + $proxies
		}
	} 

	if($proxies)
	{
		git config --global http.proxy $proxies
	}
}

function SetupPoshGit
{
	try 
	{
		# Download and install posh-git
		Write-Host "Download and install post-git..."
		$pathToInstall = Split-Path -Path $mergePath -Parent

		$currentFolder = $pwd

		cd $pathToInstall

		# Already exits?
		if((Test-Path posh-git) -eq $true)
		{
			Write-Host "Already installed - updating..."
			cd .\posh-git\
			git pull -q
		} 
		# First time installation
		else
		{
			git clone https://github.com/dahlbyk/posh-git.git -q
			cd .\posh-git\
		}
		.\install.ps1	
		
		cd $currentFolder #back out

		# Run when starting PowerShell
				$text = @"

Import-Module posh-sshell
Start-SshAgent -Quiet
"@

		$text | out-file $global:PowerProfile -append

		Write-Host "Install posh-sshell"
		PowerShellGet\Install-Module posh-sshell -Scope CurrentUser -Force
	}
	catch {
		Write-Host "While downloading and installing posh-git, something went wrong!" -Foreground Red
	}
}

function DownloadGitconfigContent2
{
	#Colors for PowerShell
	$text = @"

`$Global:GitPromptSettings.BeforeIndex.ForegroundColor              = [ConsoleColor]::Green
`$Global:GitPromptSettings.IndexColor.ForegroundColor               = [ConsoleColor]::Green
`$Global:GitPromptSettings.WorkingColor.ForegroundColor             = [ConsoleColor]::Red
`$Global:GitPromptSettings.LocalWorkingStatusSymbol.ForegroundColor = [ConsoleColor]::Red
`$Global:GitPromptSettings.LocalDefaultStatusSymbol.ForegroundColor = [ConsoleColor]::Red

# Set start location
Set-Location `$env:home
"@

	$text | out-file $global:PowerProfile -append


}

function GetSSHKey
{
	# Copy your ssh-key
	$keyPath = (Get-Item "Env:userprofile").Value + "\.ssh\id_rsa.pub"
	Get-Content $keyPath | clip	

	Write-Host "" #Empty line
	Write-Host "Your SSH-key is in you paste-bin. Use 'Ctrl+V' to paste it into the browser." -Foreground Green

	Write-Host "Go register on https://github.com/settings/ssh if you use that :)" -Foreground Green
}

CheckAdminMode
CheckPowerShellVersion
CheckIfMsysIsInstallad
CreateProfile
DownloadGit

# Reload profile to get the Git commands
.$PROFILE

DownloadGitconfigContent
SetupSSH
SetupMergeTool
SetupProxy
SetupPoshGit

# Go to the home folder
cd $env:userprofile

# Reload the profile
.$PROFILE

DownloadGitconfigContent2
GetSSHKey

.$PROFILE

Write-Host "" #Empty line
Write-Host "If you missed the paste-bin's SSH-key, get it by writing the follwing command:" 
Write-Host "cat ~/.ssh/id_rsa.pub | clip"
Write-Host "" #Empty line

cd $global:installationFolder