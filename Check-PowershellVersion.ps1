Function Check-PowershellVersion {

[CmdletBinding()]

$username = "ad\behisnippe"
$password = cat C:\temp\ingmar\credential.txt | ConvertTo-SecureString
$credentials = new-object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$password
$servers = (Get-ADComputer -LDAPFilter “(&(objectcategory=computer)(OperatingSystem=*server*))” | ? { $_.Name -notmatch "ADDC" }).Name

Foreach ($server in $servers) {

    $PSVersion = Invoke-Command -ComputerName $server -Credential $credentials -ScriptBlock { $PSVersionTable }
    
    If ($Psversion.Psversion.Major -eq "5") {

        Write-host -ForegroundColor Green "$($Server) has powershell $($PSversion.Psversion.Major), with buildversion: $($Psversion.Psversion.Build)"
        Out-File -InputObject "$($Server) has powershell $($PSversion.Psversion.Major), with buildversion: $($Psversion.Psversion.Build)" -FilePath "c:\temp\ingmar\powershellcheck.txt" -Append

    }
    Else {
        Write-Host -ForegroundColor Cyan "$($Server) has $($PSversion.Psversion.Major) and buildversion: $($Psversion.Psversion.Build)"
        Out-File -InputObject "$($Server) has $($PSversion.Psversion.Major) and buildversion: $($Psversion.Psversion.Build)" -FilePath "c:\temp\ingmar\powershellcheck.txt" -Append
    }
}

}