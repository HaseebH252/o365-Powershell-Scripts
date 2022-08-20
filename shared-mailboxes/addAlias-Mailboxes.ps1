#You need to have module installed first
## Install-Module PowerShellGet -Force
## Install-Module –Name ExchangeOnlineManagement
## CSV should have
## Name of primary email, alias


param(    
    [Parameter(Mandatory=$true,HelpMessage="Full path to create the InputFile (i.e.: C:\InputFile.csv)",Position=1)] 
    [string]$File
)

if (Get-Module -ListAvailable -Name PowershellGet ) {
    Write-Host " "
} 
else {
    Write-Host "You do not have proper modules. See begining of script for install"
    exit
}
if (Get-Module -ListAvailable -Name ExchangeOnlineManagement ) {
    Write-Host " "
} 
else {
    Write-Host "You do not have proper modules. See begining of script for install"
    exit
}


Connect-ExchangeOnline -ShowProgress $true

Write-Host "Sucessfully connected to o365. Adding Aliases"

$InputFile = Import-Csv $File
#Write-Host $InputFile

foreach ($email in $InputFile) {
    Write-Host "Adding Alias" $email.Alias "to" $email.Email
    Set-Mailbox $email.Email -EmailAddresses @{add=$email.Alias}
}