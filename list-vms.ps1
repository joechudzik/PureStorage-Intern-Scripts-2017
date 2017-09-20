<#
Code was created by Joe Chudzik for a summer internship. The code has specific information redacted, yet is still functional if the variables are assigned with meaningful information.

Lists all of the VMs with corresponding name, power state, number of CPUs, and memory capacity on a designated server. 
#>


$server = 0.0.0.0
$user = myuserlogin
$pass = myuserpassword

Connect-VIServer -Server $server -User $user -Password $pass

Get-VM |sort name |format-table name, powerstate, numcpus, memorygb

Disconnect-VIServer $server