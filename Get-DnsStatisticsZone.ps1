Function Get-DnsStatisticsZone {

<#

.SYNOPSIS:     Voer een DNS naam of IP adres in, om uit te vinden in welke zone deze zich bevind.

.DESCRIPTION:  Met set-dnssearch -computername -ip(address) kan je de record informatie opzoeken op basis van ip-adres zelfs als er geen reverse lookup record voor is.

.EXAMPLE:      set-dnssearch -computername addc011 -ip 10.42.196.13

#>

[CmdletBinding()]
param(

    [Parameter(Mandatory=$True)]
    [String]$Path,


    [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
    [ValidateLength(3,20)]
    [string]$ComputerName
    )

    begin { 
        
        If ((Test-Path -path $Path) -eq $False) {

            New-Item $Path -Type File -Force -ErrorAction SilentlyContinue -InformationAction SilentlyContinue

            Write-Host "Check alle zones voor het ip-adres: $IpAddress"
            Write-Host ""
        }
    }
        
    process{
     
        # Vind de DNS zones van de betreffende DC, die aangegeven is onder parameter computername, waar de zone een forward lookup zone van is:
        $Zones = (Get-DnsServerZone -ComputerName $ComputerName | where { $_.IsReverseLookupZone -match $False}).ZoneName

        # Voor voor elke forward lookup zone de volgende code uit:
        ForEach ($Zone in $Zones) {
            
            Get-DnsServerStatistics -Computername $Computername -ZoneName $Zone | Out-File -FilePath "$Path\$zone.txt"
        }
    }
}


