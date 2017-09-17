$Computers = Get-Content -Path "\\GDISW0780\d`$\apps\tools\ERP-Beheerservers"
$ShortCuts = "\\gdiosvm015.ad.minjus.nl\ERP_01`$\Data\Oracle_Shared\templates\PublicDesktop\*"

ForEach ($Computer in $Computers) {

    $Desktop = "\\`$Computer\c`$\users\Public"

    $FilesDestination = (get-childitem  -path '$Desktop' -recurse -force -ErrorAction SilentlyContinue -ErrorVariable DestinationFolderError)
	
	    If ($DestinationFolderError) { Write-output "De publieke desktop folder van $Computer is niet bereikbaar. Check of de server beschikbaar is." }
	
	$FilesShortcuts = (get-childitem -path "$ShortCuts" -recurse -force -ErrorAction Stop -ErrorVariable ShortcutFolderError)
	    
	    If ($ShortcutFolderError) { Write-output "De E: share folder voor de shortcuts is niet beschikbaar, check of de share beschikbaar is. Script is gestopt." }
   	
   	$ShortCutDifference = Compare-Object -ReferenceObject $FilesShortcuts -DifferenceObject $FilesDestination

    #Write-Output $ShortCutDifference | get-member -MemberType NoteProperty

    $ShortCutDifference | ForEach { 
    
        If ($_.SideIndicator -eq '<=') {
        
            Copy-Item -path $_.InputObject.FullName -Destination $Desktop -Exclude $Exclude -recurse
            Write-Host $_.InputObject.Name"is gekopieerd." -foreground Green
        }
       
        ElseIf ($_.SideIndicator -eq '=>') { 
        
            Remove-Item -path $_.InputObject.FullName
            Write-Host $_.InputObject.Name"is verwijderd." -foreground Yellow
        } 
       
        Else ($_.SideIndicator -eq '==') { 
        
            Echo "Er zijn geen nieuwe verschillen gevonden op $Computer" }
    }

}