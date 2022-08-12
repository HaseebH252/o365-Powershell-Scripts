#################################################################################################################################################################
# Purpose of this script is to remove o365 license from a list of users provided in CSV file
#                                                 
#################################################################################################################################################################

#####################################################
# CSV Formatting
#####################################################

# Create a single CSV with a header called email followed by the email addresses you want to remove licenses from
# Example: email,user1@email.com,user2@email.com 


#####################################################
# REQURIED PARAMETERS
#####################################################

# $File = CSV input file
param(    
    [Parameter(Mandatory = $true, HelpMessage = "Full path to the InputFile (i.e.: C:\InputFile.csv)", Position = 1)] 
    [string]$File
)

##################################################
# MODULES REQUIRED
#
# MS Online
##################################################

if (Get-Module -ListAvailable -Name MSOnline ) {
    Write-Host " "
} 
else {
    Write-Host "You do not have proper modules. Run Install-Module MSOnline in elevated Powershell"
    exit
}


#####################################################
# SCRIPT BODY
#####################################################


# Connect to MS Online using Modern Authentication
Connect-MsolService

$InputFile = Import-Csv $File

# Loop through each email in the CSV and remove the all licenses associated with that account
foreach ($email in $InputFile) {
    
    $user = Get-MsolUser -UserPrincipalName $email.email

    foreach ($license in $user.licenses.AccountSkuId) {

        Write-Host "Removing" $license "from" $user.displayname
        Set-MsolUserLicense -UserPrincipalName $email.email -RemoveLicenses $license
    }
    

    
}
Write-Host "Done"

#####################################################
# CLEAN UP
#####################################################

# Remove any active PowerShell sessions
Get-PSSession | Remove-PSSession

# Exit Script
exit
