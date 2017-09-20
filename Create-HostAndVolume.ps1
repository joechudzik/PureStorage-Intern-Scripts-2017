<#
Code was created by Joe Chudzik for a summer internship. The code has specific information redacted, yet is still functional if the variables are assigned with meaningful information.

Creates and connects a new host and volume with specified names for both, and size/units for the volume on a designated array given the endpoint.
#>


$ArrayName = Read-Host -Prompt 'Enter the array name'
$Endpoint = Read-Host -Prompt 'Enter the endpoint of the array'
$HostName = Read-Host -Prompt 'Enter the name of the new host'
$VolumeName = Read-Host -Prompt 'Enter the name of the new volume'
$Size = Read-Host -Prompt 'Enter the size of the volume'
$Unit = Read-Host -Prompt 'Enter the units for the size of the volume'

$cred = Get-Credential
$ArrayName = New-PfaArray -Endpoint $Endpoint -Credentials $cred -IgnoreCertificateError

New-PfaHost -Array $ArrayName -Name $HostName
New-PfaVolume -Array $ArrayName -VolumeName $VolumeName -Size $Size -Unit $Unit

New-PfaHostVolumeConnection -Array $ArrayName -VolumeName $VolumeName -HostName $HostName

Disconnect-PfaArray $ArrayName