; Source:
;    https://superuser.com/questions/1049609/search-in-autohotkey-for-a-window-title-that-contains-a-string-but-does-not-con
;    
; Accessed:
;    2019_10_23
;    
; Requires:
;    Notepad++


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; --- Global Variables --- ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

__PROCESS_NAME := "NOTEPAD++.EXE"
__PROCESS_DISPLAY_NAME := "Notepad++"
__SUBWINDOW_NAME := "Preferences"
__SUBWINDOW_SHORT_DESC := "Preferences"
__SUBWINDOW_TIMEOUT := 4  ; seconds


;;;;;;;;;;;;;;;;;;;;;
; --- Functions --- ;
;;;;;;;;;;;;;;;;;;;;;

IsNamedProcess(name) {
	global
	StringUpper, name, name
	return name = __PROCESS_NAME
}

GetActiveWindowProcessName() {
	WinGet, name, ProcessName, A
	return name
}

ActivateWindow(proc_name) {
	WinGet, windows, List
	
	Loop, %windows%
	{
		id := windows%A_Index%
		WinGet, proc_name, ProcessName, ahk_id %id%
		
		if (IsNamedProcess(proc_name)) {
			WinActivate, ahk_id %id%
			break
		}
	}
	
	name := GetActiveWindowProcessName()
	return IsNamedProcess(name)
}

OpenSubwindow() {
	SendInput !t{ENTER}
}

WaitForWindow(name, timeout) {
	WinWait, %name%,, %timeout%
	return ErrorLevel = 0
}

GetFailureMessage(short_desc, timeout) {
	msg := "Your " short_desc " could not be set."
    msg .= "`r`nThe timeout occurs at " timeout " seconds."
}

SendKeyStrokes() {
    ; Enable Multi-Editing
    SendInput {DOWN}{TAB 6}{SPACE}+{TAB 6}
    
    ; Use new style dialog when opening or saving
    SendInput {DOWN 2}{TAB 3}{SPACE}+{TAB 3}
    
    ; Disable auto-completion on each input
    SendInput {DOWN 7}{TAB 2}{SPACE}+{TAB 2}
    
    ; Confirm and close Preferences
    SendInput {HOME}{ESCAPE}
    
    ; ; OLD (2019_09_23)
    ; ; The Escape key has the same effect while leaving item list cursor in a position
    ; ; that makes this script iterable.
    ; 
    ; ; Confirm and close Preferences
    ; Send {HOME}{TAB}{SPACE}
}


;;;;;;;;;;;;;;;;;;;;;;
; --- Main Entry --- ;
;;;;;;;;;;;;;;;;;;;;;;

Main() {
	global
	if (!ActivateWindow(__PROCESS_NAME)) {
		msg := "An window for " __PROCESS_DISPLAY_NAME " could not be found in the running windows."
		MsgBox %msg%
		return
	}
	
	OpenSubwindow()
	
	if (WaitForWindow(__SUBWINDOW_NAME, __SUBWINDOW_TIMEOUT)) {
		SendKeyStrokes()
	} else {
		MsgBox, % GetFailureMessage(__SUBWINDOW_SHORT_DESC, __SUBWINDOW_TIMEOUT)
	}
}

Main()

