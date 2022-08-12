#################################################################################################################################################################
# Purpose of this script is to disable ActiveSync for a list of users provided in CSV file
#                                                 
#################################################################################################################################################################

#####################################################
# CSV Formatting
#####################################################

# Create a single CSV with a header called primarysmtpaddress followed by the email addresses you want to remove licenses from
# Example: primarysmtpaddress,user1@email.com,user2@email.com 


#####################################################
# REQURIED PARAMETERS
#####################################################

# $File = CSV input file
param(    
    [Parameter(Mandatory = $true, HelpMessage = "Full path to create the InputFile (i.e.: C:\InputFile.csv)", Position = 1)] 
    [string]$File
)


##################################################
# MODULES REQUIRED
#
# Exchange-Online
##################################################

if (Get-Module -ListAvailable -Name Exchange-Online ) {
    Write-Host " "
} 
else {
    Write-Host "You do not have proper modules. Run Install-Module Exchange-Online in elevated Powershell"
    exit
}
#####################################################
# SCRIPT BODY
#####################################################

# Connect to Exchange Online using Modern Authentication
Connect-ExchangeOnline

Write-Host "Sucessfully connected to o365. Disabling ActiveSync for Users."

$ActiveList = Import-Csv $File

foreach ($Email in $ActiveList) {

    $user = $Email.primarysmtpaddress

    Set-CASMailbox -Identity $user -ActiveSyncEnabled $false
    Write-Host "Disabled ActiveSync For" $user
}

Write-Host "Done"

#####################################################
# CLEAN UP
#####################################################

# Remove any active PowerShell sessions
Get-PSSession | Remove-PSSession

# Exit Script
exit
