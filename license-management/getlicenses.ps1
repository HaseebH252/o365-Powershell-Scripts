#Script to get list of user licenses and services

Connect-MsolService

#set output file
$outputpath = 'C:\Folder'
$date = Get-Date -Format "yyyy-MM-dd"
$tenant = (((Get-MsolDomain | Where-Object{$_.IsInitial -EQ $true}).Name).Split(".",3) | Select-Object -Index 0).ToUpper()
$outputfile = "$outputpath"+"\AzureAD_$tenant-User_SKU_Service_Audit_$date.csv"


#Get all users with a license
$LicensedUsers = Get-MsolUser -All | Where-Object{$_.isLicensed -eq $true}

#Initialize hash table
$azdatastring = @()
$azhash = ""

#Initialize progress bar Loop counter
$loopcount = 1

#Set the upper for the loop counter
$maxcount = $LicensedUsers.count


#loop through each licensed user
Foreach($LicensedUser in $LicensedUsers) {
    #Set upn for current user
    $upn = $LicensedUser.UserPrincipalName

    #Display progress bar
    $percentage = [math]::Round($loopcount / $maxcount *100) 
    $message = "Gathering license info for $UPN  ($loopcount of $maxcount)" -f $percentage
    Write-Progress -Activity $message -PercentComplete ($percentage) -Status "$percentage % Complete:  "

    #Initialize index
    [int]$index = 0
        
        #Get assigned sku's for current user
        $skus = $LicensedUser.Licenses.AccountSkuId
        
        #Set upper for sku count
        $scount = $skus.count
            
            #Get all skus, services, status, for current licensed user
            DO {
                
                #loop through each sku
                $skus | ForEach-Object{
                    $sku = $_ 
                    
                    #get services for current sku
                    $services = $LicensedUser.Licenses[$index].ServiceStatus
                        
                        #loop through each service
                        $services | ForEach-Object {
                            $service=$_ 

                            #store current service and status in hash table
                            $azhash = @{'UserPrinciPalName'=$upn;'AccountSkuId'=$sku;'ServiceName'=$service.ServicePlan.ServiceName;'ProvisioningStatus'=$service.ProvisioningStatus}
                            $azdatastring += New-Object PSObject -Property $azhash
                         }
                #increment to next sku/index
                $index++
                }

            }until ($index -eq $scount) #exit when done with all SKUs of current user

    #Increment progress bar Loop counter
    $loopcount++

}

#export hash to output file
$azdatastring |Select-Object UserPrinciPalName,AccountSkuId,ServiceName,ProvisioningStatus| Export-Csv $outputfile -NoTypeInformation