Function Get-MpioHotfixes {

<#

        .SYNOPSIS:     Load a serverlist and check per server based on it's version-number if a certain hotfix, is installed. If not, write the servername to an output-file.

        .DESCRIPTION:  Get-MpioHotFixes -InputPath -OutPath 

        .EXAMPLE:      Get-MpioHotFixes -InputPath "C:\temp\Ingmar\serverlist.txt" -OutPath "C:\temp\Ingmar\Missing-Hotfixes.txt"

#>

        [CmdletBinding()]
            param(

                [Parameter(Mandatory=$false)]
                [string]$InputPath,

                [Parameter(Mandatory=$false)]
                [string]$OutPath
            )
Begin {
    
    $InputPath   = "c:\temp\Ingmar\serverlist.txt"
    $OutPath     = "c:\temp\Ingmar\Missing.txt"
    $Servers     =  Get-Content -Path $InputPath -Force 
        
    #[array]$OS   = "6.0.6001","6.0.6002","6.1.7600","6.1.7601","6.2.9200","6.3.9600"
        
    $W2008Sp1    = "6.0.6001"
    $W2008Sp2    = "6.0.6002"
    $W2008R2     = "6.1.7600"
    $W2008R2Sp1  = "6.1.7601"
    $W2012       = "6.2.9200"
    $W2012R2     = "6.3.9600"

# If the input path doesn't exist, then show and error. If the output file is there, the

    If (Test-path $Outpath) {
        remove-item $Outpath -recurse -force 
    }
    If (!(Test-Path $InputPath)) {
        Write-Host "No serverlist is available at given location." 
    }
       
}

Process {
  
# Begin Script with adding a line telling which KB article is needed on the different OS versions:

        Out-File -Append $OutPath -InputObject "KB2754704 test on Windows 2008 SP1, Windows 2008 SP2, Windows 2008 R2, Windows 2008 R2 SP1: `r`n"

        Foreach ($Server in $Servers) {

# Test if KB2754704 is availabe on Windows 2008 SP1, Windows 2008 SP2, Windows 2008 R2, Windows 2008 R2 SP1 (Buildnumbers 6.0.6001, 6.0.6002, 6.1.7600, 6.1.7601)

            If (([string](Get-WmiObject -Class win32_OperatingSystem -computername $Server -ErrorAction SilentlyContinue).Version -eq $W2008Sp1) -OR 
                ([string](Get-WmiObject -Class win32_OperatingSystem -computername $Server -ErrorAction SilentlyContinue).Version -eq $W2008Sp2) -OR 
                ([string](Get-WmiObject -Class win32_OperatingSystem -computername $Server -ErrorAction SilentlyContinue).Version -eq $W2008R2)  -OR 
                ([string](Get-WmiObject -Class win32_OperatingSystem -computername $Server -ErrorAction SilentlyContinue).Version -eq $W2008R2Sp1)) {

    # If a hotfix is installed on the server, then write that to host in green. 
                   
                If (get-hotfix -ComputerName $Server -ErrorAction SilentlyContinue | ? { $_.HotFixID -eq "KB2754704" })  {
                       
                    Write-Host -ForegroundColor Green "Hotfix KB2754704 is installed on $($Server)."
                }
 
    # Else write to host and a output file, that the specific KB article is needed on the servers.

                else {
                    
                    Out-File -Append -FilePath $OutPath -InputObject "Hotfix KB2754704 is needed on $($Server)."
                    Write-Host -ForegroundColor DarkYellow "Hotfix KB2754704 is needed on $($Server)."
                }
         
            }

# This shows the servers that are not in the scope.
 
            Else {               
               
                Write-host "Hotfix KB2754704 is not needed on ($server)."

            }
        }

        Out-File -Append $OutPath -InputObject "`r`n KB2821052 test on Windows 2008 R2, Windows 2008 R2 SP1:`r`n"
        
        Foreach ($Server in $Servers) {
        
#Test if KB2821052 is availabe on Windows 2008 R2, Windows 2008 R2 SP1 (Buildnumbers 6.1.7600, 6.1.7601)

            If (([string](Get-WmiObject -Class win32_OperatingSystem -computername $Server -ErrorAction SilentlyContinue).Version -eq $W2008R2)  -OR 
                ([string](Get-WmiObject -Class win32_OperatingSystem -computername $Server -ErrorAction SilentlyContinue).Version -eq $W2008R2Sp1)) {
                    
                If (get-hotfix -ComputerName $Server -ErrorAction SilentlyContinue | ? { $_.HotFixID -eq "KB2821052" })  {
                       
                    Write-Host -ForegroundColor Green "Hotfix KB2821052 is installed on $($Server) (2008 server)."
                }
                else {
                    Out-File -Append -FilePath $OutPath -InputObject "Hotfix KB2821052 is needed on $($Server)."
                    Write-Host -ForegroundColor DarkYellow "Hotfix KB2821052 is needed on $($Server)."
                }
         
            }
            Else {               
                
                Write-host "Hotfix KB2754704 is not needed on ($server)."

            }
        }
    
        Out-File -append $OutPath -InputObject "`r`n KB2878031 test on Windows 2008 SP2:`r`n"
            
        Foreach ($Server in $Servers) {

#Test if KB2878031 is availabe on Windows 2008 SP2 (Buildnumbers 6.0.6002)

            If ([string](Get-WmiObject -Class win32_OperatingSystem -computername $Server -ErrorAction SilentlyContinue).Version -eq $W2008Sp2) {
                    
                If (get-hotfix -ComputerName $Server -ErrorAction SilentlyContinue | ? { $_.HotFixID -eq "KB2821052" })  {
                       
                    Write-Host -ForegroundColor Green "Hotfix KB2821052 is installed on $($Server) (2008 server)."
                }
                else {
                    Out-File -Append -FilePath $OutPath -InputObject "Hotfix KB2821052 is needed on $($Server)."
                    Write-Host -ForegroundColor DarkYellow "Hotfix KB2821052 is needed on $($Server)."
                }
         
            }
            Else {               
                
                Write-host "Hotfix KB2821052 is not needed on ($server)."

            }
        }

        Out-File -append $OutPath -InputObject "`r`n KB3046101 test on Windows Server 2012 and 2012 R2:`r`n"

        Foreach ($Server in $Servers) {

#Test if KB3046101 is availabe on Windows Server 2012 and 2012 R2 (Buildnumbers 6.2.9200, 6.3.9600)

            If (([string](Get-WmiObject -Class win32_OperatingSystem -computername $Server -ErrorAction SilentlyContinue).Version -eq $W2012)  -OR 
                ([string](Get-WmiObject -Class win32_OperatingSystem -computername $Server -ErrorAction SilentlyContinue).Version -eq $W2012R2)) {
                    
           #     If (get-hotfix -ComputerName $Server -ErrorAction SilentlyContinue | ? { $_.HotFixID -eq "KB3046101" })  {
                       
           #         Write-Host -ForegroundColor Green "Hotfix KB3046101 is installed on $($Server)."

           #     }
                
           #     Else {

           #         Out-File -Append -FilePath $OutPath -InputObject "Hotfix KB3046101 is needed on $($Server)."
           #         Write-Host -ForegroundColor DarkYellow "Hotfix KB3046101 is needed on $($Server)."
                    
           #     }

                If (get-hotfix -ComputerName $Server -ErrorAction SilentlyContinue | ? { $_.HotFixID -eq "KB3121261" })  {
                       
                    Write-Host -ForegroundColor Green "Hotfix KB3121261 is installed on $($Server)."

                }
                
                Else {

                    Out-File -Append -FilePath $OutPath -InputObject "Hotfix KB3121261 is needed on $($Server)."
                    Write-Host -ForegroundColor DarkYellow "Hotfix KB3121261 is needed on $($Server)."
                    
                }
         
            }
            Else {               
                
                Write-host "Hotfix KB3046101 / KB3121261 is not needed on ($server)."

            }

       }
    }
End {

}
}