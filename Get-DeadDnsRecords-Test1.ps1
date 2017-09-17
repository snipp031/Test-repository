$ComputerName = "addc011"

$Zones = (Get-DnsServerZone -ComputerName $ComputerName | where { $_.IsReverseLookupZone -match $False}).ZoneName

ForEach ($Zone in $Zones) 

{ $Records = Get-DnsServerResourceRecord -computername $Computername -ZoneName $Zone -RRType A

#| where { ($_.hostname -notmatch '_ldap.') -AND 
# ($_.hostname -notmatch '_kerberos.') -AND 
# ($_.hostname -notmatch '@') -AND
# ($_.hostname -notmatch '_kpasswd.') -AND
#  ($_.hostname -notmatch '_msc')} | Select-Object -Property Hostname,RecordData)
 
    Foreach ($Record in $Records) {
    
#If ((Test-NetConnection -ComputerName ($Record.ipv4address.ipaddresstostring) -ErrorAction SilentlyContinue).Pingsucceeded -eq $False) {           
#If ([ipaddress]$Record.recorddata.ipv4address.IPAddressToString -eq $True) {

If ((Test-NetConnection -ComputerName ($Record.recorddata.ipv4address.IPAddressToString)).PingSucceeded -eq $true) { Write-Host -ForegroundColor Green "$($Record.hostname) is Alive!"} Else {Write-Host -ForegroundColor Yellow "$($Record.hostname) is Dead!"}
                   
    }
}