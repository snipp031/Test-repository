Function Get-Uptime {

    [cmdletbinding()]

    Param(

        [parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)][String[]]$Computerlist
    )


Process {

    Foreach ($computername in $Computerlist) {

    write-host "$($computername)"

        If ((Test-NetConnection -ComputerName $Computername -InformationLevel Quiet -WarningAction SilentlyContinue) -eq 'True') {

            If ($OsInfo = get-wmiobject -ComputerName $Computername -class win32_operatingsystem -ErrorAction SilentlyContinue) {

                $Status = [String]"Ok"
                $Uptime = ((Get-date) - ($OsInfo.ConvertToDateTime($OsInfo.LastBootUptime))).Days
                $StartTime = $OsInfo.ConvertToDateTime($OsInfo.LastBootUpTime)
            
    
                $UptimeObject = New-Object -TypeName PSobject
                $UptimeObject | Add-Member -MemberType NoteProperty -Name Computername -Value $Computername
                $upTimeObject | Add-Member -MemberType NoteProperty -Name StartTime -Value $StartTime
                $UptimeObject | Add-Member -MemberType NoteProperty -Name "Uptime (Days)" -Value $Uptime
                $upTimeObject | Add-Member -MemberType NoteProperty -Name Status -Value $Status

            }
            Else { 

                $Status = [String]"ERROR"

                $UptimeObject = New-Object -TypeName PSobject 
                $UpTimeObject | Add-Member -MemberType NoteProperty -Name Computername -Value $Computername 
                $UpTimeObject | Add-Member -MemberType NoteProperty -Name Status -Value $Status
            }
        }
        Else {
        
            $Status = [String]"OFFLINE"
        
            $UptimeObject = New-Object -TypeName PSobject 
            $UpTimeObject | Add-Member -MemberType NoteProperty -Name Computername -Value $Computername
            $UpTimeObject | Add-Member -MemberType NoteProperty -Name Status -Value $Status
        }

    }
}
}



