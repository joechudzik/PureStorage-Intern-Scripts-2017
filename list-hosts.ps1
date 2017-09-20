<#
Code was created by Joe Chudzik for a summer internship. The code has specific information redacted, yet is still functional 
if the variables are assigned with meaningful information.

Lists all the hosts with corresponding WWNs on the designated array with corresponding endpoint.
#>


$cred = Get-Credential
$endpoint = 0.0.0.0

$array1 = New-PfaArray -EndPoint $endpoint -Credentials $cred -IgnoreCertificateError

Get-PfaHosts $array1 |sort name |format-table name, wwn

Disconnect-PfaArray $array1