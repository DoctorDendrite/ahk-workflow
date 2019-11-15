*. 2019_10_18   New: Convert-HotstringsToMappedFunctions.ahk
*. 2019_10_18   Ren: Set-ExplorerFileSettings.ahk -> Set-ExplorerPreferences.ahk
*. 2019_10_22   Mod: Toggle-NppPreferences.ahk
*. 2019_10_22   New: Disable-MsWordProofing.ahk
*. 2019_10_23   New: Compare-Directories.ps1
*. 2019_10_23   New: Guard-Session.ps1
*. 2019_10_23   Mod: Hotstrings\Convert-HotstringsToMappedFunctions.ahk
*. 2019_10_24   Mod: Convert-HotstringsToMappedFunctions.ahk
*. 2019_10_30   Ren: Compare-Directories.ps1 -> Compare-ChildItem.ps1
*. 2019_10_30   Mod: Hotstrings\Math.ahk
*. 2019_10_30   Bug: Hotstrings\Math_Map.ahk

    Des: Does not produce any of the unicode symbols in the replacer hotstrings
    
*. 2019_11_06   Mod: Disable-MsWordProofing.ahk

    Bug/typo fix:
    
        `__SUBWINDOW_TIMOUT` -> `__SUBWINDOW_TIMEOUT`
        
*. 2019_11_06   Mod: Set-NppPreferences.ahk

    Bug/typo fix:
    
        `__SUBWINDOW_TIMOUT` -> `__SUBWINDOW_TIMEOUT`
        
*. 2019_11_06   Bug: Run-TopDriveInExplorer.ahk

    Des: Fails to identify flash drive
    Fix:
    
        Default set to FIXED drives
        Flash drive is REMOVABLE type
        
*. 2019_11_06   Mod: Run-TopDriveInExplorer.ahk

    '--type' parameter is now multivalued:
    
        '--type=fixed,removable'
        
    `__HELP_MSG`: Replaced multiline concatentation with multiline string
    
*. 2019_11_06   Mod: Convert-HotstringsToMappedFunctions.ahk

    Description:
    
        Replaced all instances of
        
            ``
            Loop %0%
            {
            ``
            
        with
        
            `` for index, param in A_Args {
            
    Note: Untested
    
*. 2019_11_06   Mod: Compare-ChildItem.ps1

    Bug fix on Line 23:
    
        `` if ($output.Count -gt 0) {
        ->
        `` if ($output.Count -eq 0) {
        
    Added '-Full' switch to differentiate terse and verbose output
    
*. 2019_11_13   New: README.md
*. 2019_11_14   Mod: Set-ExplorerPreferences.ahk

	Bug fix on Line 26:
	
		``return`` -> ``break``
		