<#
Code was created by Joe Chudzik for a summer internship. The code has specific information redacted, yet is still functional if the variables are assigned with meaningful information.

Program will remove the named volume and host from the named array of specific endpoint.
#>


$arrayName = Read-Host -Prompt 'Enter the name of the array'
$Endpoint = Read-Host -Prompt 'Enter the endpoint of the array'
$volumeName = Read-Host -Prompt 'Enter the name of the volume'
$hostName = Read-Host -Prompt 'Enter the name of the host'


$cred = Get-Credential
$arrayName = New-PfaArray -Endpoint $Endpoint -Credentials $cred -IgnoreCertificateError

Remove-PfaHostVolumeConnection $arrayName -VolumeName $volumeName -HostName $hostName

Remove-PfaVolumeOrSnapshot -Array $arrayName -Name $volumeName 
Remove-PfaHost -Array $arrayName -Name $hostName

Disconnect-PfaArray $arrayName