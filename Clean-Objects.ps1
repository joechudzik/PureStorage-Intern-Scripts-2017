<#
Code was created by Joe Chudzik for a summer internship. The code has specific information redacted, yet is still functional if the variables are assigned with meaningful information.

This code is designed to search through a VMware environment and delete anything that is not following a specific naming convention. The code will access the vCenter environment as well as a specific array.
#>


#initializes variables and settings for email
$myEmail = “FakeEmail@gmail.com”  #password - password
$password = ConvertTo-SecureString “password” -AsPlainText -Force
$SMTP = "smtp.gmail.com"
# add other emails to the email list by following the same syntax as below
$To = “FakeAddress@gmail.com”, “me@gmail.com”
$Date = Get-Date
$Subject = "Items Deleted " + $Date
$Body = ""
$Creds = New-Object System.Management.Automation.PSCredential ($myEmail,$password)

#
#Connecting to array
#
$pass = ConvertTo-SecureString “password” -AsPlainText -Force
$endpoint = 0.0.0.0
$array1 = New-PfaArray -Endpoint $endpoint -UserName “username” -Password $pass -IgnoreCertificateError

#
#Connecting to vCenter
#
$server = 0.0.0.0
Connect-VIServer -Server $server -User “username” -Password “password”


#
#THE FOLLOWING VARIABLE IS THE NAMING CONVENTION. ANYTHING THAT IS ASSIGNED WILL BE NOT BE DELETED
#

$namingConvention = “test”


#
#BLOCK 1 (VMs)
#
$body += "VM clean up: `r`n"
$VMs = Get-VM |where {-not $_.name.startswith($namingConvention)}
#
#Loops through VMs, powers off VMs that need to be, then deletes VMs that do not follow the naming standard
#
foreach( $vm in $VMs ){
    if( $vm.powerstate -eq "PoweredOn" ){
        $body += $vm.name +" powered off `r`n"
        #code to power off vm
        Stop-VM -VM $vm -Confirm:$False
    }
    #code to delete vm
    Remove-VM -VM $vm -Confirm:$False
    $body += $vm.name +" deleted `r`n"
}
$body += "`r`n `r`n"


#
#BLOCK 2 (Datastores)
#
$body += "Datastore clean up: `r`n"
$esxHosts = Get-VMHost -Location “testCluster”
$destinationDatastore = Get-Datastore -Name “testDatastore" -Location “testLab"
#
#Loops through datastores on each host in “testCluster" that do not follow naming standard, moves any VMs, if any, 
#on that datastore, then deletes datastore
#
foreach( $host1 in $esxHosts ){
    $datastores = Get-Datastore -VMHost $host1 |where {-not $_.name.StartsWith($namingConvention)}
    foreach( $datastore in $datastores ){
        $VMsOnDatastore = Get-VM -Datastore $datastore
        foreach( $vm in $VMsOnDatastore ){
            Move-VM -VM $vm -Datastore $destinationDatastore
            $body += $vm.name +" on datastore "+ $datastore.name +" was moved to testDatastore `r`n"
        }
        Remove-Datastore -Datastore $datastore -VMHost $host1 -Confirm:$False
        $body += $datastore.name +" datastore deleted `r`n"
    }
}
$body += "`r`n `r`n"


#
#BLOCK 3 (Volumes)
#
$body += "Volume clean up: `r`n"
$volumes = Get-PfaVolumes $array1
#
#Loops through available volumes and deletes those that do not follow the naming standard
#
foreach( $volume in $volumes ){
    if(-not $volume.name.startsWith($namingConvention)) {
        #collects and removes the volume and host connections
        $hostConnections = Get-PfaVolumeHostConnections $array1 -VolumeName $volume.name
        foreach( $connection in $hostConnections ){
            Remove-PfaHostVolumeConnection $array1 -VolumeName $volume.name -HostName $connection.host
        }
        #collects and removes the volume and host group connections
        $hgroupConnections = Get-PfaVolumeHostGroupConnections $array1 -VolumeName $volume.name
        foreach( $hgroup in $hgroupConnections ){
            Remove-PfaHostGroupVolumeConnection $array1 -VolumeName $volume.name -HostGroupName $hgroup.hgroup
        }
        #code to remove volumes 
        Remove-PfaVolumeOrSnapshot $array1 -Name $volume.name
        $body += $volume.name +" deleted `r`n"
        }
}
$Body += "`r`n `r`n"


#
#BLOCK 4 (Protection Groups)
#
$body += "Protection group clean up: `r`n"
$protectionGroups = Get-PfaProtectionGroups -Array $array1
#
#Loops through available protection groups and deletes those that do not follow the naming standard
#
foreach( $protectionGroup in $protectionGroups ) {
    if( -not $protectionGroup.name.startswith($namingConvention) ){
        #code to remove protection group
        Remove-PfaProtectionGroupOrSnapshot -Array $array1 -Name $protectionGroup.name
        $body += $protectionGroup.name +" deleted `r`n"
    }
}
$body += "`r`n `r`n"


#
#BLOCK 5 (Hosts)
#
$body += "Host clean up: `r`n"
$hosts = Get-PfaHosts -Array $array1 |where {-not $_.name.startswith($namingConvention)}
#
#Loops through available hosts and deletes those that do not follow the naming standard and do not have a WWN or IQN
#
foreach( $host1 in $hosts ) {
    #if(-not $host1.wwn -and -not $host1.iqn){
        #tests if the chosen host has a volume on it and disconnects the volume
        $volsOnHost = Get-PfaHostVolumeConnections $array1 $host1
        foreach( $vol in $volsOnHost ) {
            Remove-PfaHostVolumeConnection $array1 -VolumeName $vol.vol -HostName $host1
        }
        #code to remove host
        Remove-PfaHost $array1 -Name $host1.name
        $body += $host1.name +" deleted `r`n"
    #}
}
$body += "`r`n `r`n"


#
#BLOCK 6 (Host groups)
#
$body += "Host group clean up: `r`n"
$hGroups = Get-PfaHostGroups $array1
#
#Loops through available host groups and deletes by naming standard
#
foreach( $hgroup in $hGroups ) {
    if(-not $hgroup.name.startsWith($namingConvention)) {
        if(-not $hgroup.hosts) {
            #code to remove host groups
            Remove-PfaHostGroup $array1 -Name $hgroup.name
            $body += $hgroup.name +" deleted `r`n"
        }
        else {
            $body += $hgroup.name +" was not deleted `r`n"
        }
    }
}
$body += "`r`n `r`n"



#sends the email
Send-MailMessage -to $to -from $myEmail -Subject $Subject -Body $Body -SmtpServer $SMTP -UseSsl -Credential $Creds -port 587


Disconnect-VIServer $server -Confirm:$false
Disconnect-PfaArray $array1