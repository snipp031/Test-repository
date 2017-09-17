Function Get-ComputerInfo {
 
      [CmdletBinding()]
 
      Param(
      [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)] 
      [string[]]$computername, 
      [string]$logfile = 'c:\scripts\unreachable.txt',
      [string]$outfile = 'c:\scripts\computerinfo.csv'
 
      )
 
BEGIN {

      Remove-Item $logfile –erroraction silentlycontinue
 
}
 
PROCESS {
 
      Foreach ($computer in $computername) {

            $continue = $true
            try {
 
                  $os = Get-WmiObject –class Win32_OperatingSystem –computername $computer –erroraction Stop
 
            } catch {
 
                  $continue = $false
                  "$computer is not reachable" | Out-File $logfile -append
 
            }
 

            if ($continue) {
 
                  $bios = Get-WmiObject –class Win32_BIOS –computername $computer
                  $os = Gwmi win32_operatingsystem -cn $computer
                  $mem = get-wmiobject Win32_ComputerSystem -cn $computer | select @{name="PhysicalMemory";Expression={"{0:N2}" -f($_.TotalPhysicalMemory/1gb).tostring("N0")}},NumberOfProcessors,Name,Model
                  $cpuinfo = "numberOfCores","NumberOfLogicalProcessors","maxclockspeed","addressWidth"


                  [string[]]$cpudata = Get-WmiObject -class win32_processor –computername $computer -Property $cpuinfo | Select-Object -Property $cpuinfo

                  $phyv = Get-WmiObject win32_bIOS -computer $computer | select serialnumber

                  $res = "Physical” # Assume "physical machine" unless resource has "vmware" in the value or a "dash" in the serial #                 


                  if ($phyv -like "*-*" -or $phyv -like "*VM*" -or $phyv -like "*vm*") { $res = "Virtual" } # else

                  #{                  

                   # Find all active NICs and IP of the NIC

                   $Networks = gwmi Win32_NetworkAdapterConfiguration -ComputerName $computer | ? {$_.IPEnabled}

                     foreach ($Network in $Networks) {[string[]]$IPAddress += ("[" + $Network.IpAddress[0] + " " + $Network.MACAddress + "]")}

                   $ActiveIPs = $IPAddress

                   $Networks = gwmi -ComputerName $computer win32_networkadapter | where-object { $_.physicaladapter }

                     foreach ($Network in $Networks) {

                       #if ({$_.$Network.MACAddress}) {[string[]]$MACinfo += "#" + $Network.DeviceID + "-" + $Network.MACAddress} else {[string[]]$MACinfo += "#" + $Network.DeviceID + "-Dis"}

                       [string[]]$MACinfo += "#" + $Network.DeviceID + "-" + $Network.MACAddress

                     }

                   $obj = New-Object –typename PSObject

# DISPLAY Section ($obj - output to screen)
# - For "report-ONLY," you can comment out the "$obj" (11 lines) below

                   $obj | Add-Member –membertype NoteProperty –name ComputerName –value ($computer) –PassThru |
                          Add-Member –membertype NoteProperty –name Hardware –value ($res) -PassThru |
                          Add-Member –membertype NoteProperty –name OperatingSystem –value ($os.Caption) -PassThru |
                          Add-Member –membertype NoteProperty –name ServicePack –value ($os.ServicePackMajorVersion) -PassThru |
                          Add-Member –membertype NoteProperty –name "PhysicalMemory(GB)" –value ($mem.PhysicalMemory) -PassThru |
                          Add-Member –membertype NoteProperty –name Processors –value ($mem.numberofprocessors)  -PassThru |
                          Add-Member –membertype NoteProperty –name CPUInfo –value ($cpudata) -PassThru |
                          Add-Member –membertype NoteProperty –name IPAddress –value ($ActiveIPs) -PassThru  |
                          Add-Member –membertype NoteProperty –name NICs –value ($MACinfo) -PassThru |
                          Add-Member –membertype NoteProperty –name Serial -value ($phyv)

# REPORT Section ($csv - output to file)

                   $csv = $computer + "," `
                           + $res + "," `
                           + $os.Caption +"," `
                           + $os.ServicePackMajorVersion + "," `
                           + $mem.PHysicalmemory + "," `
                           + $mem.numberofprocessors + "," `
                           + $cpudata + "," `
                           + $ActiveIPs + "," `
                           + $MACinfo + "," `
                           + $phyv

                   Write-Output $obj
                   #Write-Output $csv - uncomment this to debug the report output line
                   #Write $csv | Out-File $outfile -append

                 # } # End of Else ($res = "Physical)

            } # End of IF (continue)
            
      } # End of ForEach
 
  } # End of Process

END {}
 
} # End Function