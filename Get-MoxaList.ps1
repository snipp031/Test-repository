Import-Module ActiveDirectory

#Get all servers available in active directory

$Servers = Get-ADComputer -Filter {OperatingSystem -Like "Windows Server*"} -Property * | select Name

#Ga elke serer langs en haal de dynamic tcp port range op. In een format (GDISW0634 - Start port range: 1025 | End port range: 65984).

Foreach ($Server in $Servers) { $Application = Invoke-command -ErrorAction SilentlyContinue -computername $Server.Name -scriptblock { Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | where { $_.displayname -match "moba" } }  
                                
                                If ($Application) {
                                                                
                                Write-Host "$($Application)"
                                }
                                Else {
                                Write-Host "$($Server.name) has no MobaXterm installed."
                                }

                                # | OUt-File "C:\temp\Ingmar\MobaXterm-Lijst.csv" -Append
                                    #Export-csv -Path "C:\temp\Ingmar\MobaXterm-Lijst.csv" -Append

}