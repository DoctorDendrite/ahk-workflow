; Requires:
;    Set-NppPreferences.ahk
;    Hotstrings.ahk

;;;;;;;;;;;;;;;;;;;;;
; --- Constants --- ;
;;;;;;;;;;;;;;;;;;;;;

; Machines that allow the use of downloaded executables
; -----------------------------------------------------
;   LIM000-000

__hotstrings_file := A_ComputerName ~= "LIM\d{3}-\d{3}" ? "Master.exe" : "Master.ahk"

;;;;;;;;;;;;;;;;;;;;;
; --- Functions --- ;
;;;;;;;;;;;;;;;;;;;;;

GetDate() {
    FormatTime dateString,, yyyy_MM_dd
    return dateString
}

GetDateTimeString() {
    FormatTime dateString,, yyyy_MM_dd_HHmmss
    return dateString
}

GetWorkingDrive() {
    return RegExReplace(A_WorkingDir, "\\.*")
}

NewWorkstation() {
    ; ; OLD (2019_09_26)
	; ; To avoid data loss, I'm moving away naming folders using just the date stamp.
	; 
	; date := GetDate()
	
	date := GetDateTimeString()
    drive := GetWorkingDrive()
    root := "temp"
    subdir := ""
    dir := drive . "\" . root . "\" . date . "\" . subdir
    FileCreateDir, %dir%
    return dir
}

RunAndWaitForProcess(process_name) {
    Process, Exist, %process_name%
    
    if (ErrorLevel = 0) {
        Run, %process_name%
        
        ; Wait for process to start.
        Process, Exist, %process_name%
        
        while (ErrorLevel = 0) {
            Process, Exist, %process_name%
        }
    }
}

MoveAll(src_patterns, dst) {
    IfNotExist, %dst%
        FileCreateDir, %dst%
        
	for index, pattern in src_patterns {
		Loop, Files, %pattern%
		{
			; Note: The `A_LoopFilePath` binding does not work in this case. The `A_LoopFileFullPath` binding is
			; considered a misnomer, but it works properly (according to its name) when `Loop` iterates using a
			; fully-qualified directory path.
			FileMove, %A_LoopFileFullPath%, %dst%\*.*
			
			if (!FileExist(dst . "\" . A_LoopFileFullName)) {
				MsgBox, Failed to move the file: %A_LoopFileName%
				return 1
			}
		}
	}
    
    return 0
}

;;;;;;;;;;;;;;;;;;
; --- Script --- ;
;;;;;;;;;;;;;;;;;;

holding_dir := "__HOLD"
path := NewWorkstation()
RunAndWaitForProcess("notepad++.exe")

dir := RegExReplace(A_WorkingDir, "\\$")
src_patterns := [dir . "\*.ahk"]

if (!(__hotstrings_file ~= "\.ahk$")) {
	src_patterns.Push(dir . "\" . __hotstrings_file)
}

dst := path . holding_dir  ; There's no need to add a '\' delimiter since function `NewWorkstation`
                           ; automatically adds one to the end when the `subdir` local binding is empty.
                           
if (MoveAll(src_patterns, dst) != 0) {
    ExitApp
}

Sleep, 1000
RunWait, %dst%\Set-NppPreferences.ahk
Run, %dst%\%__hotstrings_file%
Gosub, ShowPathToWorkstation
Return

;;;;;;;;;;;;;;;;;;;;;;;
; --- Subroutines --- ;
;;;;;;;;;;;;;;;;;;;;;;;

ShowPathToWorkstation:
    Gui, Add, Edit, w280 ReadOnly, %path%
    Gui, Add, Button, w0 h0 Hidden Default, AlternateClose
    Gui, Show, w300 h50, Path to Workstation
    Return
    
ButtonAlternateClose:
    Gui, Destroy
    ExitApp
    
GuiEscape:
    Gui, Destroy
    ExitApp
    
GuiClose:
    ExitApp
    