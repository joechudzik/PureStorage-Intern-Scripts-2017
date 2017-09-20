<#
Code was created by Joe Chudzik for a summer internship. The code has specific information redacted, yet is still functional if the variables are assigned with meaningful information.

Lists all the datastores with corresponding type, amount of free space, and capacity on the designated server
#>

$server = 0.0.0.0
$user = myuserlogin
$pass = myuserpassword


Connect-VIServer -Server $server -User $user -Password $pass

Get-Datastore |format-table name, type, freespacegb, capacitygb

Disconnect-VIServer $server