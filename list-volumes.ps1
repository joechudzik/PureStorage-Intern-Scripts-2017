<#
Code was created by Joe Chudzik for a summer internship. The code has specific information redacted, yet is still functional if the variables are assigned with meaningful information.

Lists all the volumes with corresponding creation date and size on the designated array
#>


$cred = get-credential
$endpoint = 0.0.0.0

$array1 = New-PfaArray -EndPoint $endpoint -Credentials $cred -IgnoreCertificateError

Get-PfaVolumes $array1 |sort name |format-table name, created, size

Disconnect-PfaArray $array1
