
#################################################################################################################################################################
# Purpose of this script is to create a 
# Distribution list and add memebers.
#                                                 
# You will need to provide path for CSV with new group infomation
#################################################################################################################################################################

#####################################################
# CSV Formatting
#####################################################
# CSV should be in format
# Name,DisplayName,Alias,Address,Owner,Members
#
# name,name,alias,email,owner,member1;member2

##################################################
# MODULES REQUIRED
# PowershellGet
# Exchange-Online
##################################################

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


#####################################################
# REQURIED PARAMETERS
#####################################################

param(    
    [Parameter(Mandatory = $true, HelpMessage = "Full path to create the InputFile (i.e.: C:\InputFile.csv)", Position = 1)] 
    [string]$File
)


#####################################################
# SCRIPT BODY
#####################################################

Connect-ExchangeOnline -ShowProgress $true


Write-Host "Sucessfully connected to o365. Creating Lists with Members"


$DGList = Import-Csv $File

foreach ($DG in $DGList) {

    $Members = $DG.Members -split ";"
    
    New-DistributionGroup -Name $DG.Name -DisplayName $DG.DisplayName -Alias $DG.Alias -PrimarySmtpAddress $DG.Address -ManagedBy $DG.Owner -Members $Members
    Write-Host $DG.Address "created."    
}

# To just add members to existing group
# Add-DistributionGroupMember -Identity $email.adress -Member $email.Members


#####################################################
# CLEAN UP
#####################################################

# Remove any active PowerShell sessions
Get-PSSession | Remove-PSSession

# Exit Script
exit