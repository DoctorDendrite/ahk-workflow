

;;;;;;;;;;;;;;;;;;;;;
; --- Functions --- ;
;;;;;;;;;;;;;;;;;;;;;

IsWindowsExplorerClass(class) {
	return class = "ExploreWClass" || class = "CabinetWClass" || class = "Progman"
}

GetActiveWindowProcessName() {
	WinGet, name, ProcessName, A
	return name
}

ActivateExplorerWindow() {
	WinGet, windows, List
	
	Loop, %windows%
	{
		id := windows%A_Index%
		WinGetClass, class, ahk_id %id%
		
		if (IsWindowsExplorerClass(class)) {
			WinActivate, ahk_id %id%
			break
		}
	}
	
	WinGetClass, class, A
	return IsWindowsExplorerClass(class)
}

GetRegistryValue(keyname, valuename) {
	RegRead, out, %keyname%, %valuename%
	return out
}

SendKeyStrokes() {

	; Value Name		Desired Value		Key Combination
	; 										
	; Hidden			1					HH
	; HideFileExt		0					HF
	; AutoCheckSelect	1					HT
	
	key := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
	
	show_hidden_files := GetRegistryValue(key, "Hidden")
	hide_file_extensions := GetRegistryValue(key, "HideFileExt")
	show_item_checkboxes := GetRegistryValue(key, "AutoCheckSelect")
	
	if (show_hidden_files != 1) {
		SendInput, !vhh
	}
	
	if (hide_file_extensions != 0) {
		SendInput, !vhf
	}
	
	if (show_item_checkboxes != 1) {
		SendInput, !vht
	}
}


;;;;;;;;;;;;;;;;;;;;;;
; --- Main Entry --- ;
;;;;;;;;;;;;;;;;;;;;;;

Main() {
	if (!ActivateExplorerWindow()) {
		msg := "An Explorer window could not be found in the running windows."
		MsgBox %msg%
		return
	}
	
	SendKeyStrokes()
}

Main()

