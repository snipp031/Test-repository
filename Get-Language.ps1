Import-Module ActiveDirectory

#Get all servers available in active directory

$Servers = Get-ADComputer -Filter {OperatingSystem -Like "Windows Server*"} -Property * | select Name

#Ga elke serer langs en haal de dynamic tcp port range op. In een format (GDISW0634 - Start port range: 1025 | End port range: 65984).

Foreach ($Server in $Servers) {

    invoke-command -ComputerName $server.name -ScriptBlock { $language = (get-culture).Name }

    write-host "$($server.name) - $($language)"

}