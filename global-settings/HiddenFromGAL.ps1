#You need to have module installed first
## Install-Module PowerShellGet -Force
## Install-Module –Name ExchangeOnlineManagement
param(    
    [Parameter(Mandatory = $true, HelpMessage = "Full path to create the OutputFile (i.e.: C:\MyOutputFile.csv)", Position = 1)] 
    [string]$OutputFile
)

Connect-ExchangeOnline -ShowProgress $true

Write-Host "Checking All Hidden Users in GAL..."

Get-Mailbox -ResultSize Unlimited | Where-Object { $_.HiddenFromAddressListsEnabled -eq $True } | Select-Object DisplayName, UserPrincipalName, HiddenFromAddressListsEnabled | Export-CSV "$OutputFile" -NoTypeInformation -Encoding UTF8

Write-Host "Completed"