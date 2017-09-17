
Function Convert-FromSecureStringToPlaintext ( $SecureString ) {

[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString))

}

Function Read-ServerAttributes {

#Alle Server attributen + Servernaam etc inlezen

}


Function Add-KeePassItem { 

[cmdletbinding()]

Param (

    [parameter(Mandatory = $True)][String]$PathToDb,
    [parameter(Mandatory = $False)][String]$PathToKeyFile
    
)

################## Opzet parameters en openen KeePass Database ##################

#Keepass Folder 
$PathToKeePassFolder = "C:\Program Files (x86)\KeePass Password Safe 2"

#Loading .Net assemblies voor Keepass
$KeePassExe = Join-Path -Path $PathToKeePassFolder -ChildPath "KeePass.exe" 
[Reflection.Assembly]::LoadFile($KeePassEXE)

#Keepass Database Folder (Tijdelijk hardcoded)
$PathToDB = 'C:\temp\ingmar\PowerShell.kdbx'

#Maak een samengestelde sleutel aan voor de verbinding met de database.
$Compositekey = New-Object KeePassLib.Keys.CompositeKey

#KCP: UserAccount verbinding
$KcpUserAccount = New-Object KeePassLib.Keys.KcpUserAccount

#KCP: Key File verbinding (als de database daarmee beveiligd is)
$PathToKeyFile = 'C:\temp\Ingmar\Powershell.key'
$KcpKeyFile = New-Object KeePassLib.Keys.KcpKeyFile($PathToKeyFile)

#KCP: Wachtwoord verbinding
$Password = Read-Host -Prompt "Voer wachtwoord in:" -AsSecureString
$Password = Convert-FromSecureStringToPlaintext -SecureString $Password
$KcpPassword = New-Object KeePassLib.Keys.KcpPassword($Password)

#Voeg Key file en wachtwoord toe aan compositekey variabele
$CompositeKey.AddUserKey( $KcpPassword )
$CompositeKey.AddUserKey( $KcpKeyFile )

#Stel het Keepass database pad in
$IOConnectionInfo = New-Object KeePassLib.Serialization.IOConnectionInfo
$IOConnectionInfo.Path = $PathToDB

#Recording object declaratie
$StatusLogger = New-Object KeePassLib.Interfaces.NullStatusLogger

#Open de database, met alle voorgaande variabelen
$Database = New-Object KeePassLib.PwDatabase
$Database.Open($IOConnectionInfo,$Compositekey,$StatusLogger)

################## Opzet parameters en openen KeePass Database Voltooid ##################

#Sla locatie met KeePass folder met alle servers en local admin wachtwoorden op in een variabele
$KeePassFolder = $PwDatabase.RootGroup.Groups.Groups | ? { $_.name -eq "Window Servers" }

#Check of er niet per ongeluk meerdere of geen folders met overeenkomstige naam te vinden is
If ($KeePassFolder.Count -eq 0) {

    Trow "Foutmelding: Kan de juiste KeePass group niet vinden!" ; Return 

}
Elseif ($$KeePassFolder -gt 1) {

    Trow "Foutmelding: Meerdere folders gevonden!" ; Return

}

#Array with all servers and their local admin password attributes
$ServerAttributeArray = @()


$NewEntry = New-Object -TypeName KeePassLib.PwEntry( $KeePassFolder[0], $True, $True )

$pTitle = New-Object KeePassLib.Security.ProtectedString($True, $Title)
$pUser = New-Object KeePassLib.Security.ProtectedString($True, $UserName)
$pPW = New-Object KeePassLib.Security.ProtectedString($True, $Password)
$pURL = New-Object KeePassLib.Security.ProtectedString($True, $URL)
$pNotes = New-Object KeePassLib.Security.ProtectedString($True, $Notes)

$NewEntry.Strings.Set("Title", $pTitle)
$NewEntry.Strings.Set("UserName", $pUser)
$NewEntry.Strings.Set("Password", $pPW)
$NewEntry.Strings.Set("URL", $pURL)
$NewEntry.Strings.Set("Notes", $pNotes)

$PwDatabase.Close()
$KcpPassword = $null

}