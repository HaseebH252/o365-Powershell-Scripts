#################################################################################################################################################################
# Purpose of this script is to provide expiration date for Office cloud accounts
#                                                 
#################################################################################################################################################################



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

try {
    # Connect to MS Online using Modern Authentication
    Connect-MsolService

    Write-Host "Sucessfully connected to o365. Press CTRL + C to Terminate"

    # Loop checking accounts until script has been terminated
    while ($true) {

        # Get UPN from user
        $Account = Read-Host -Prompt 'Input the UPN for account to check: '
        $UserPrincipal = Get-MsolUser -UserPrincipalName $Account
        
        # Check to see if password is set to never expire
        $UserPrincipal | Format-List PasswordNeverExpires

        # Get last password change date
        $PasswordLastChange = $UserPrincipal.LastPasswordChangeTimestamp

        # Password interval 
        $password_expire_Interval = 90

        # Set date which password will expire on
        $PassExpireDate = $PasswordLastChange.AddDays($password_expire_Interval)
        Write-host "Password will Expire on : $PassExpireDate"


        # Calculate how many days left before password expires.
        $StartDate = (GET-DATE)
        $DaysLeft = NEW-TIMESPAN -Start $StartDate -End $PasswordLastChange
        $DaysLeft = $password_expire_Interval - ([math]::Abs([math]::Floor($DaysLeft.TotalDays)))


        Write-host "Password will Expire in $DaysLeft Days"
        $UserPrincipal | Select-Object DisplayName, LastPasswordChangeTimeStamp, @{Name = ”PasswordAge”; Expression = { (Get-Date) - $_.LastPasswordChangeTimeStamp } } | sort-object PasswordAge -desc

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