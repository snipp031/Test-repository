Function Get-DnsSearch {

<#

.SYNOPSIS:     Voer een DNS naam of IP adres in, om uit te vinden in welke zone deze zich bevind.

.DESCRIPTION:  Met set-dnssearch -computername -ip(address) kan je de record informatie opzoeken op basis van ip-adres zelfs als er geen reverse lookup record voor is.

.EXAMPLE:      set-dnssearch -computername addc011 -ip 10.42.196.13

#>

[CmdletBinding()]
param(

    [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
    [Alias('ip')]
    $DNSLookup,


    [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
    [ValidateLength(3,50)]
    [string]$ServerName
    )

    begin  { 
        
        #$Logfiles = "c:\temp\Ingmar\"
        #Write-Output "Check alle zones voor het ip-adres: $DNSLookup"
        #Remove-Item -Path $Logfiles -WhatIf
    }

    process{
        
        $Zones = (Get-DnsServerZone -ComputerName $ServerName).ZoneName

        ForEach ($Zone in $Zones) {
       
            Get-DnsServerResourceRecord -Computername $ServerName -ZoneName $Zone | ? { ($_.RecordData.IPv4Address -match "$DNSLookup") -OR
                                                                                        ($_.RecordData.HostNameAlias -match "$DNSLookup") -OR 
                                                                                        ($_.HostName -match "$DNSLookup") }
            #Get-DnsServerStatistics -Computername $ServerName -ZoneName $Zone | Out-File -FilePath "$LogFiles\$zone.txt"
        }
    }
} 
