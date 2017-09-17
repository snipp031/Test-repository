Function Get-DeadDnsRecords {

<# Get-DnsServerResourceRecord

.SYNOPSIS:    Find stale DNS records that don't respond on a test-netconnection and report them to a result file.

.DESCRIPTION:  Use command: "Get-deaddnsrecords -computername <computername or ip-address> -path <result file path>"

.EXAMPLE:      "get-deaddnsrecords -computername "DC01.Contoso.com" -path "c:\temp\results.txt"

#>

[CmdletBinding()]
param(

    [Parameter(Mandatory=$True)]
    [String]$path,

<# 

The following parameter $computername will be able to accept pipeline input. So we can get results from multiple DNS servers.

#>

    [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
    [ValidateLength(3,20)]
    [string]$ComputerName,

<# 

The following parameter $Zone will be able to accept pipeline input. And is not mandatory. You can choose whether to check all records or just one zone.

#>


    [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
    [ValidateLength(3,20)]
    [string]$Zone
    )

    begin { 
        
<#

We will test if the result path variable does already exist and if not, we will create the file. The file
will be overwritten, the next time you run the function.

Also I will write a title in console.


#>
         
        If ((Test-Path -path $Path) -eq $False) {

            New-Item $Path -Type File -Force -ErrorAction SilentlyContinue -InformationAction SilentlyContinue
        }
        
        Write-Host "Check op alle zones voor non-responsive dns-records:"
        Write-Host ""
    }

    process {

<#

This is the main part of the script, where we walk through all zones and avoid the reversed lookup zones. After fetching all
the forward lookup zones, we are going to begin by creating a zone-title and write the output to console and file.

After this we will begin to fetch all DNS records per zone and then test each record for a positive ping result. If that result
is negative, then we will write the stale DNS record to file.

This will create a big file with all the stale DNS records, categorised by forward lookup zone naam.

#>
       
# Get all zones-names and don't retrieve the reversed lookup zones. Put them in a variable. 

        $Zones = (Get-DnsServerZone -ComputerName $ComputerName | where { $_.IsReverseLookupZone -match $False}).ZoneName

# For each statement to go through all zones:

        ForEach ($Zone in $Zones) {

# Write the zone-naam as title in the console and to the results file in parameter $path.

        Write-Host -ForegroundColor Blue "$Zone"
        Write-Host -ForegroundColor Blue " "
        Out-file $Path -InputObject "$Zone DNS ZONE" -Append
                    
# Fetch all the A-records and leave uit the global catalog servers and nameservers. Select the hostname and the recorddata containing the ip-addresses and save them to $Records.

        $Records = (Get-DnsServerResourceRecord -computername $Computername -ZoneName $Zone.ZoneName -RRType A | where { ($_.hostname -notmatch '@') -AND ($_.hostname -notmatch 'gc' )} | Select-Object -Property Hostname,RecordData)

# For each statement to go through all A-type dns-records.
                          
            Foreach ($Record in $Records) {

# Perform a test-netconnection and to be certain of failure extend to maximum TTL. Write the result if true to console. 
                        
                        #If ((Test-NetConnection -InformationLevel Quiet -hops 120 -ComputerName ($Record.recorddata.ipv4address)).PingSucceeded -eq $True) {
                        If ((Test-NetConnection -InformationLevel Quiet -OutBuffer 16 -hops 120 -ComputerName ($Record.recorddata.ipv4address)) -eq $True) {

                        Write-Host -ForegroundColor Green "$($Record.hostname) is Alive!"

                        }
                        
# Perform a test-netconnection in the else-statement and write back all failures to console and the results file $path.                        
                                              
                        #Elseif ((Test-NetConnection -ComputerName ($Record.recorddata.ipv4address)).PingSucceeded -eq $False) {
                        Else {

                        Write-Host -ForegroundColor Yellow "       $($Record.hostname) is Dead!"
                        Out-file $Path -append -InputObject "       $($Record.hostname) is Dead!"
                        }
            }

       }

    }
} 

