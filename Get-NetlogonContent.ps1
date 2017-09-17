Function Get-NetlogonContents {

[CmdletBinding()]


#read-host -assecurestring | convertfrom-securestring | out-file C:\temp\ingmar\credential.txt
$username = "ad\adisnippe"
$password = cat C:\temp\ingmar\credential.txt | ConvertTo-SecureString
$credentials = new-object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$password
$servers = (Get-ADComputer -LDAPFilter “(&(objectcategory=computer)(OperatingSystem=*server*))” | ? { ($_.Name -match "ADDC") -AND (!($_.Name -eq "ADDC005"))}).Name


$OutputFile = "\\gdisw0634\d$\_temp\paul\netlogon\Netlogon-content.log"
Remove-Item $OutputFile

    Foreach ($server in $servers) {
        
        Out-File -LiteralPath $OutputFile -append -InputObject "Netlogon.log from server: $($server) `r`n"
        $content = Invoke-command -ComputerName $server -Credential $credentials -ScriptBlock { cat c:\windows\debug\netlogon.log } | Out-File $OutputFile -Append
        Out-File -LiteralPath $OutputFile -append -InputObject "`r`n"
    }
}
