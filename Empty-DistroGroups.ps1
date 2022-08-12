#################################################################################################################################################################
# Purpose of this script is to generate a CSV
# file with all distribution lists that are empty.
#                                                 
# You will need to provide path on
# where to generate CSV file.
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
# REQURIED PARAMETERS
#####################################################


# $outFile = Output path of the CSV report
param(    
    [Parameter(Mandatory=$true,HelpMessage="Full path where to Output CSV report (i.e.: C:\InputFile.csv):",Position=1)] 
    [string]$outFile
)


#####################################################
# SCRIPT BODY
#####################################################

# Connect to Exchange Online using Modern Authentication
Connect-ExchangeOnline



Get-DistributionGroup -ResultSize Unlimited | Where-Object { (Get-DistributionGroupMember $_.PrimarySMTPAddress | Measure-Object).Count -eq 0 } | Select-Object DisplayName,PrimarySMTPAddress | Export-Csv $outFile

#####################################################
# CLEAN UP
#####################################################

# Remove any active PowerShell sessions
Get-PSSession | Remove-PSSession

# Exit Script
exit