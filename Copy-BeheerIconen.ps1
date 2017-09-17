$Computers = @("GDISW0781")

foreach ($computer in $computers) {

    $Exclude = "\\gdiosvm015.ad.minjus.nl\ERP_01$\Shortcut_test\Copy-BeheerIconen.ps1"

	$FilesDestination = Invoke-command -computername $Computer -ErrorAction SilentlyContinue -ErrorVariable DestinationFolderError -ScriptBlock { get-childitem "\\$Computer\c$\users\Public\Desktop" -Recurse -force | FT } 
	
	If ($DestinationFolderError) { Write-output "De publieke public folder van $computer is niet bereikbaar. Check of de server beschikbaar is." }
	
	$FilesShortcuts = get-childitem "\\GDISW0780\c$\users\Public\Desktop" -Recurse -force | FT -ErrorAction SilentlyContinue -ErrorVariable ShortcutFolderError
	
	If ($ShortcutFolderError) { 

        Write-output "De shared folder voor de shortcuts is niet beschikbaar, check of de share nog aanwezig is" 
    }
   	

	Compare-Object -ReferenceObject $FilesShortcuts -DifferenceObject $FilesDestination 
	
	#Copy-Item -path "c:\scripts\*" -Destination "\\$Computer\c$\users\Public\Desktop" -Exclude $Exclude -recurse -verbose
        
}

