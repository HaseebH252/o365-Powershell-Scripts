#################################################################################################################################################################
# Purpose of this script is to get a list of mailboxes a user is member of
#################################################################################################################################################################

Connect-ExchangeOnline

Write-Host "This Script will find all shared mailboxes a user has access to.. May take some time to run"

while ($true) {
    $Account = Read-Host -Prompt 'Input the user name. Type exit to terminate'
    if ($Account -eq 'exit') {
        break
    }

    Get-Mailbox -Filter { recipienttypedetails -eq "SharedMailbox" } | Get-Mailboxpermission -User $Account
}

Remove-PSSession $Session
exit
