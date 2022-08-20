#################################################################################################################################################################
# Purpose of this script is to remove members of a Distribution List
#################################################################################################################################################################

#####################################################
# CSV Formatting
#####################################################
# Create a single CSV with a header called email followed by the group addresses 
# Example: email,group1@email.com,group2@email.com 

##################################################
# MODULES REQUIRED
# PowershellGet
# Exchange-Online
##################################################

if (Get-Module -ListAvailable -Name PowershellGet ) {
    Write-Host " "
} 
else {
    Write-Host "You do not have proper modules. Run Install-Module PowershellGet in elevated Powershell"
    exit
}
if (Get-Module -ListAvailable -Name Exchange-Online ) {
    Write-Host " "
} 
else {
    Write-Host "You do not have proper modules. Run Install-Module Exchange-Online in elevated Powershell"
    exit
}


#####################################################
# REQURIED PARAMETERS
#####################################################
# $File = Input path of the CSV report
param(    
    [Parameter(Mandatory = $true, HelpMessage = "Full path to the InputFile (i.e.: C:\InputFile.csv)", Position = 1)] 
    [string]$File
)

#####################################################
# SCRIPT BODY
#####################################################

# Connect to Exchange Online using Modern Authentication
Connect-ExchangeOnline
Write-Host "Sucessfully connected to o365. Removing Members"



$InputFile = Import-Csv $File
$groupname = $InputFile.Email

foreach ($email in $groupname) {

    $members = Get-DistributionGroupMember -Identity $email

    foreach ($member in $members) {

        Write-Host $member "Removing from DL" $email
        Remove-DistributionGroupMember -Identity $email -Member $member.PrimarySmtpAddress -Confirm:$false
    }
}


Write-Host "`n`nSetting Owners of All DLs"
# You can set the new owner of all the empty distros if you plan to use them later

$SetOwner = ""

foreach ($email in $groupname) {

    foreach ($owner in $email) {

        Write-Host "Changed Owner of DL" $email "to" $SetOwner
        Set-DistributionGroup -Identity $email -ManagedBy $SetOwner
    }
}


#####################################################
# CLEAN UP
#####################################################

# Remove any active PowerShell sessions
Get-PSSession | Remove-PSSession

# Exit Script
exit