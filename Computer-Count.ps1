Function Count-DomainComputers {

[CmdletBinding()]


$servers = Get-ADComputer -LDAPFilter “(&(objectcategory=computer)(OperatingSystem=*server*))”
Write-Host "Aantal computers in dit domein: $($Servers.count)"

}