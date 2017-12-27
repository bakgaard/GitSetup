#Run the following command with quotations:
# ./GitSetup "Your name" "Your email"

param(
	[Parameter(Mandatory=$true)] [string]$name, 
	[Parameter(Mandatory=$true)] [string]$mail
)

$global:x86 = $true
$global:PowerProfile = $PROFILE
$global:ConfigFile = ".gitconfig"
$global:P4MergeFile = "P4Merge.zip"
$global:gitPath = "${env:ProgramFiles(x86)}" + "\Git"
$global:mergePath = $gitPath + "\libexec\git-core\mergetools"
$global:installationFolder = $pwd;

function CheckIfMsysIsInstallad
{
	# Check if MSysGit has been installed
	$ValidPath = Test-Path $gitPath
	If($ValidPath -eq $false)
	{
		$global:x86 = $false
		$global:gitPath = "${env:ProgramFiles}" + "\Git"
		$global:mergePath = $gitPath + "\mingw64\libexec\git-core\mergetools"
	}

	$ValidPath = Test-Path $global:gitPath
	# It has not:
	If ($ValidPath -eq $false) 
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
Set-Alias g git

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
Set-Alias g git 

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
	}
	catch	
    {
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

function SetupPostGit
{
	try 
    {
		# Download and install posh-git
		Write-Host "Download and install post-git"
        $pathToInstall = Split-Path -Path $mergePath -Parent

        $currentFolder = $pwd

        cd $pathToInstall

        If((Test-Path posh-git) -eq $false)
        {
           Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm

	        git clone -q https://github.com/dahlbyk/posh-git.git
	        cd posh-git
            ./install.ps1	
        }
        cd $currentFolder
	}
	catch {
		Write-Host "While downloading and installing posh-git, something went wrong!" -Foreground Red
	}
}

function DownloadGitconfigContent2
{
	#Colors for PowerShell
	$text = @"
Start-SshAgent -q #This prompt you for password on start of PowerShell and remembers it for all origin interactions

`$Global:GitPromptSettings.BeforeIndexForegroundColor        = [ConsoleColor]::Green
`$Global:GitPromptSettings.IndexForegroundColor              = [ConsoleColor]::Green
`$Global:GitPromptSettings.WorkingForegroundColor            = [ConsoleColor]::Red
`$Global:GitPromptSettings.LocalWorkingStatusForegroundColor = [ConsoleColor]::Red
"@

	$text | out-file $global:PowerProfile -append
}

function GetSSHKey
{
	# Copy your ssh-key
	$keyPath = (Get-Item "Env:userprofile").Value + "/.ssh/id_rsa.pub"
	Get-Content $keyPath | clip	

    Write-Host "" #Empty line
	Write-Host "Your SSH-key is in you paste-bin. Use 'Ctrl+V' to paste it into the browser." -Foreground Green

	Write-Host "Go register on https://github.com/settings/ssh if you use that :)" -Foreground Green
}

CheckIfMsysIsInstallad
CreateProfile
DownloadGit

# Reload profile to get the Git commands
.$PROFILE

DownloadGitconfigContent
SetupSSH
SetupMergeTool
SetupProxy
SetupPostGit

# Go to the home folder
cd $env:userprofile

# Reload the profile
.$PROFILE

DownloadGitconfigContent2
GetSSHKey

.$PROFILE

Write-Host "To get your ssh-key in your paste-bin, write the follwing command:"
Write-Host "Get-Content ~/.ssh/id_rsa.pub | clip "

cd $global:installationFolder