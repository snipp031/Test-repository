Import-Module ActiveDirectory

#Get all servers available in active directory

$Servers = Get-ADComputer -Filter {OperatingSystem -Like "Windows Server*"} -Property * | select Name

#Ga elke serer langs en haal de dynamic tcp port range op. In een format (GDISW0634 - Start port range: 1025 | End port range: 65984).

Foreach ($Server in $Servers) {

    [string]$NetshResult  = Invoke-Command -ComputerName $Server.name -ScriptBlock { netsh int ipv4 show dynamicport tcp } -ErrorAction SilentlyContinue
    
    If ($NetshResult -match "was not found") {

        Out-File -InputObject "$($Server.name) is a Windows 2003.. $%&@*!" -FilePath c:\temp\Ingmar\Servers-DynamicPortList.txt -Append
   
    }

    Elseif ($NetshResult) {

        [int32]$Startrange  = ($NetshResult -replace '\s','').Split(":")[1].Substring(0,$Text.IndexOf('N'))
        [int32]$Portrange  = ($NetshResult -replace '\s','').Split(":")[2]
        [int32]$EndRange    = $Portrange - $Startrange

        Out-File -InputObject "$($Server.name) - Start Port range: $($Startrange) | End Port range: $($EndRange)" -FilePath c:\temp\Ingmar\Servers-DynamicPortList.txt -Append
    }

    Else {

        Out-File -InputObject "Cannot run netsh on $($Server.name), server is not online or does not exist." -FilePath c:\temp\Ingmar\Servers-DynamicPortList.txt -Append 

    }

}