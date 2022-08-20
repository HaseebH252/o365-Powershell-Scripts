# You need to have module installed first
## Install-Module PowerShellGet -Force
## Install-Module –Name ExchangeOnlineManagement

Connect-ExchangeOnline -ShowProgress $true

$domains = Get-AcceptedDomain
#$mailboxes = Get-Mailbox -ResultSize Unlimited

Write-Host "Sucessfully connected to o365. Enter Account to Check external Forwarding Rules. Type All to run against all; exported as CSV"
Write-Host "Type Exit to exit"


while ($true) {
    $Account = Read-Host -Prompt 'Input the user name'
    if ($Account -eq 'Exit') {
        break
    }
    elseif ($Account -eq 'All') {
        Write-Host "Checking Forwarding Rules for All Mailboxes..."
    
        $mailboxes = Get-Mailbox -ResultSize Unlimited
    
        foreach ($mailbox in $mailboxes) {
            $forwardingRules = $null
            Write-Host "Checking rules for $($mailbox.displayname) - $($mailbox.primarysmtpaddress)" -foregroundColor Green
            $rules = get-inboxrule -Mailbox $mailbox.primarysmtpaddress
     
            $forwardingRules = $rules | Where-Object { $_.forwardto -or $_.forwardasattachmentto }
 
            foreach ($rule in $forwardingRules) {
                $recipients = @()
                $recipients = $rule.ForwardTo | Where-Object { $_ -match "SMTP" }
                $recipients += $rule.ForwardAsAttachmentTo | Where-Object { $_ -match "SMTP" }
     
                $externalRecipients = @()
 
                foreach ($recipient in $recipients) {
                    $email = ($recipient -split "SMTP:")[1].Trim("]")
                    $domain = ($email -split "@")[1]
 
                    if ($domains.DomainName -notcontains $domain) {
                        $externalRecipients += $email
                    }    
                }
 
                if ($externalRecipients) {
                    $extRecString = $externalRecipients -join ", "
                    Write-Host "$($rule.Name) forwards to $extRecString" -ForegroundColor Yellow
 
                    $ruleHash = $null
                    $ruleHash = [ordered]@{
                        PrimarySmtpAddress = $mailbox.PrimarySmtpAddress
                        DisplayName        = $mailbox.DisplayName
                        RuleId             = $rule.Identity
                        RuleName           = $rule.Name
                        RuleDescription    = $rule.Description
                        ExternalRecipients = $extRecString
                    }
                    $ruleObject = New-Object PSObject -Property $ruleHash
                    $ruleObject | Export-Csv C:\scripts\externalrules.csv -NoTypeInformation -Append
                }
            }
        }

        Write-Host "CSV Generated.Completed"
    }
    else {
        $singleMailbox = Get-Mailbox -Identity $Account
        $forwardingRules = $null
        Write-Host "Checking rules for $($singleMailbox.displayname) - $($singleMailbox.primarysmtpaddress)" -foregroundColor Green
        $rules = get-inboxrule -Mailbox $singleMailbox.primarysmtpaddress
     
        $forwardingRules = $rules | Where-Object { $_.forwardto -or $_.forwardasattachmentto }
 
        foreach ($rule in $forwardingRules) {
            $recipients = @()
            $recipients = $rule.ForwardTo | Where-Object { $_ -match "SMTP" }
            $recipients += $rule.ForwardAsAttachmentTo | Where-Object { $_ -match "SMTP" }
     
            $externalRecipients = @()
 
            foreach ($recipient in $recipients) {
                $email = ($recipient -split "SMTP:")[1].Trim("]")
                $domain = ($email -split "@")[1]
 
                if ($domains.DomainName -notcontains $domain) {
                    $externalRecipients += $email
                }    
            }
 
            if ($externalRecipients) {
                $extRecString = $externalRecipients -join ", "
                Write-Host "$($rule.Name) forwards to $extRecString" -ForegroundColor Yellow
            }
        }
    }
}