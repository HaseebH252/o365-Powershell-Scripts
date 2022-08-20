
#################################################################################################################################################################
# Purpose of this script is to disable Clutter feature on select Exchange mailboxes
#                                                 
#################################################################################################################################################################

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

Write-Host "Sucessfully connected to o365. Press CTRL + C to Terminate"

# Loop on accounts until script has been terminated
try {
    while ($true) {

        $Account = Read-Host -Prompt 'Input the email address of the user'
    
        Set-Clutter -Identity $Account -Enable $false

        Write-Host "This has been completed successfully for this" $Account

    }
}

#####################################################
# CLEAN UP
#####################################################

finally {

    # Remove any active PowerShell sessions
    Write-Host "Killing any active sessions"
    Get-PSSession | Remove-PSSession

    # Exit Script
    exit
}