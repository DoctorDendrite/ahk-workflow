#SingleInstance Force
#Persistent
#Include %A_ScriptDir%\Monitor.ahk


; **********************
; * --- DICTIONARY --- *
; **********************

if (!__names) {
	__names:= {}
}
__names["stop"] := "function_0000"
__names["start"] := "function_0001"
__names["kill"] := "function_0002"
__names["panic"] := "function_0003"
__names["help"] := "function_0004"
__names["ppane"] := "function_0005"
__names["preview"] := "function_0005"
__names["dpane"] := "function_0006"
__names["details"] := "function_0006"
__names["calendar"] := "function_0007"
__names["formats"] := "function_0008"
__names["list"] := "function_0009"
__names["t"] := "function_0010"
__names["titlecase"] := "function_0010"
__names["tounix"] := "function_0011"
__names["todos"] := "function_0012"
__names["tab2space"] := "function_0013"
__names["block"] := "function_0014"
__names["block_tab4"] := "function_0015"
__names["block_tab8"] := "function_0016"
__names["condense"] := "function_0017"
__names["condense_tab4"] := "function_0018"
__names["condense_tab8"] := "function_0019"
__names["top"] := "function_0020"
__names["date"] := "function_0021"
__names["prettydate"] := "function_0022"
__names["time"] := "function_0023"
__names["datetime"] := "function_0024"
__names["last"] := "function_0025"
__names["title"] := "function_0026"
__names["d_title"] := "function_0027"
__names["dt_title"] := "function_0028"
__names["d_-_title"] := "function_0029"
__names["dt_-_title"] := "function_0030"
__names["last_Sun"] := "function_0031"
__names["lSun"] := "function_0031"
__names["last_Mon"] := "function_0032"
__names["lMon"] := "function_0032"
__names["last_Tue"] := "function_0033"
__names["lTue"] := "function_0033"
__names["last_Wed"] := "function_0034"
__names["lWed"] := "function_0034"
__names["last_Thu"] := "function_0035"
__names["lThu"] := "function_0035"
__names["last_Fri"] := "function_0036"
__names["lFri"] := "function_0036"
__names["last_Sat"] := "function_0037"
__names["lSat"] := "function_0037"
__names["next_Sun"] := "function_0038"
__names["nSun"] := "function_0038"
__names["next_Mon"] := "function_0039"
__names["nMon"] := "function_0039"
__names["next_Tue"] := "function_0040"
__names["nTue"] := "function_0040"
__names["next_Wed"] := "function_0041"
__names["nWed"] := "function_0041"
__names["next_Thu"] := "function_0042"
__names["nThu"] := "function_0042"
__names["next_Fri"] := "function_0043"
__names["nFri"] := "function_0043"
__names["next_Sat"] := "function_0044"
__names["nSat"] := "function_0044"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; --- Global Variables --- ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

__bin_path := A_ScriptDir
__date_format := "yyyy_MM_dd"
__pretty_date_format := "d MMMM yyyy"
__secnd_separator := "_-_" ; "_"
__text_space := "   "
__tab_size := 4
__note_width := 85
__browser_process_names := [
    , "chrome.exe"
    , "firefox.exe"
    , "MicrosoftEdge.exe"
    , "iexplore.exe"]


; **********************
; * --- MAIN ENTRY --- *
; **********************

Call(script_param) {
	global
	Func(__names[script_param]).Call()
}

loop %0% {
	script_param := %A_Index%

	if (StrLen(script_param) > 0) {
		Call(script_param)
	}

	Monitor.Exit()
}


; *******************
; * --- CONTENT --- *
; *******************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;
; --- Functions --- ;
;;;;;;;;;;;;;;;;;;;;;

DisplayHelpMessage() {
    msg := "STRING REPLACEMENTS"
        .  "`n`n`;date`;`t`tReplace with current date."
        .  "`n`n`;time`;`t`tReplace with current time."
        .  "`n`n`;datetime`;`tReplace with current date and time."
        .  "`n`n`;title`;`t`tReplace with a title-corrected string from the"
        .  "`n`t`tClipboard."
        .  "`n`n`;d_title`;"
        .  "`n`;d_-_title`;`t`tReplace with current date and title string."
        .  "`n`n`;dt_title`;"
        .  "`n`;dt_-_title`;`tReplace with current date and time and title string."
        .  "`n`n`;lxxx`;`t`tReplace with the date of the last weekday"
        .  "`n`t`t(Sun - Mon)."
        .  "`n`n`;nxxx`;`t`tReplace with the date of the next weekday"
        .  "`n`t`t(Sun - Mon)."
        .  "`n`n`nCOMMANDS"
        .  "`n`n`;kill`;`t`t`tTerminate AutoHotkey and the expected"
        .  "`n`t`t`tcompiled version of this script."
        .  "`n`n`;ppane`;"
        .  "`n`;preview`;`t`t`tToggle the Preview Pane in"
        .  "`n`t`t`tWindows Explorer."
        .  "`n`n`;dpane`;"
        .  "`n`;details`;`t`t`tToggle the Details Pane in"
        .  "`n`t`t`tWindows Explorer."
        .  "`n`n`;help`;`t`t`tDisplay this help message."
        .  "`n`nStop-HotStr"
        .  "`nStop-HotStrings"
        .  "`nDisable-HotStrings"
        .  "`nHotStr=0`t`t`tTemporarily disable this script"
        .  "`n`nStart-HotStr"
        .  "`nStart-HotStrings"
        .  "`nEnable-HotStrings"
        .  "`nHotStr=1`t`t`tRe-enable this script"
    MsgBox % msg
    return
}

GetDate(format) {
    FormatTime dateString,, %format%
    return dateString
}

GetStdDate() {
    global
    return GetDate(__date_format)
}

GetPrettyDate() {
    global
    return GetDate(__pretty_date_format)
}

GetTime() {
    FormatTime timeString,, HHmmss
    return timeString
}

GetDateAndTime() {
    return GetStdDate() "_" GetTime()
}

GetNextDate(dayCode, factor := 1) {
    distance := factor * (dayCode - A_WDay)
    distance := distance < 0 ? 7 + distance : distance
    date := A_Year
    date += A_YDay + factor * (distance = 0 ? 7 : distance) - 1, days
    FormatTime, dateString, %date%, %__date_format%
    return dateString
}

GetLastDate(dayCode) {
    return GetNextDate(dayCode, -1)
}

ToTitleCase(str) {
    StringUpper, str, str, T
    return StrReplace(str, "`n")
}

ToUpperCamelCase(str) {
    StringUpper, str, str, T
    str := RegExReplace(str, ":", "_")
    return RegExReplace(str, "`r`n|[^0-9A-Za-z_`-``']")
}

ToUnixString(str) {
    str := StrReplace(str, "+", "{+}")
    str := StrReplace(str, "\", "/")
    return StrReplace(str, "`n")
}

ToDosString(str) {
    str := StrReplace(str, "+", "{+}")
    str := StrReplace(str, "/", "\")
    return StrReplace(str, "`n")
}

NextSlack(slack, tab, loopField) {
    return slack = 1 or loopField = "`r" or loopField = "`n"
           ? tab : slack - 1
}

ReplaceTabsWithSpaces(str) {
    global
    output := ""
    slack := __tab_size
    
    Loop, Parse, str
    {
        if (A_LoopField = "`t") {
            i := 1
            
            while (i <= slack) {
                output .= A_Space
                i := i + 1
            }
            
            slack := __tab_size
        } else {
            output .= A_LoopField
            slack := NextSlack(slack, __tab_size, A_LoopField)
        }
    }
    
    return output
}

GetLengthOfString(str, tab) {
    output := ""
    slack := tab
    len := 0
    
    Loop, Parse, str
    {
        if (A_LoopField = "`t") {
            i := 1
            
            while (i <= slack) {
                len := len + 1
                i := i + 1
            }
            
            slack := __tab_size
        } else {
            len := len + 1
            slack := NextSlack(slack, __tab_size, A_LoopField)
        }
    }
    
    return len
}

GetLeadingWhitespace(str) {
    output := ""
    
    Loop, Parse, str
    {
        if (RegExMatch(A_LoopField, "\s") > 0) {
            output .= A_LoopField
        } else {
            return output
        }
    }
    
    return output
}

CondenseBrokenLines(str) {
    lines := StrSplit(str, "`r`n")
    output := ""
    leading_space := ""
    last_line_was_blank := true
    i = 1
    
    ; If the first line is blank, take its whitespace as leading space for the next
    ; line. Then output with a newline.
    if (i <= lines.MaxIndex() and IsEmptyOrWhiteSpace(lines[i])) {
        leading_space := lines[i]
        output .= leading_space . "`r`n"
        i := i + 1
    }
    
    while (i <= lines.MaxIndex()) {
        if (IsEmptyOrWhiteSpace(lines[i])) {
            ; If this line is blank, start a new line with the previous leading
            ; space.
            output .= "`r`n" . leading_space
            
            ; End this line only if it isn't the last line in the text.
            if (i < lines.MaxIndex()) {
                output .= "`r`n"
            }
            
            last_line_was_blank := true
        } else {
            ; If this line is not blank...
            if (last_line_was_blank) {
                ; Start a new line and record this line's whitespace.
                leading_space := GetLeadingWhiteSpace(lines[i])
                output .= lines[i]
                last_line_was_blank := false
            } else {
                ; Condense all non-blank lines onto one line.
                output .= " " . lines[i]
            }
        }
        
        i := i + 1
    }
    
    return output
}

BlockText(str, tab, len) {
    global
    command := __bin_path "\block.exe --tabsize=" tab " --length=" len " """ str """"
    return ComObjCreate("WScript.Shell").Exec(command).StdOut.ReadAll()
}

PasteBlockText(str, tab, len) {
    str := StrReplace(str, "`n")
    str := StrReplace(str, """", "\""")  ; This is stupid.
    block := BlockText(str, tab, len)
    Clipboard := block
    SendInput ^v
    return
}

PasteCondensedBlockText(str, tab, len) {
    str := CondenseBrokenLines(str)
    PasteBlockText(str, tab, len)
    return
}

GetTitle(header, footer, separator1, separator2 := "") {
    return header . separator1
                  . (StrLen(separator2) > 0 ? GetSubtitle(footer, separator2)
                                            : ToUpperCamelCase(footer))
}

GetAuthorship(str) {
    str := RegExReplace(str, "[^0-9A-Za-z_]+$|(^.*[^0-9A-Za-z_])(?=(\w|_)+$)")
    return str
}

IsEmptyOrWhiteSpace(str) {
    return RegExMatch(str, "^\s*$")
}

GetSubtitle(footer, separator := "") {
    if (StrLen(separator) > 0) {
        index := 1
        parts := StrSplit(footer, "`r`n")
        
        while (index < parts.MaxIndex() and IsEmptyOrWhiteSpace(parts[index]))
            index := index + 1
            
        subtitle := parts[index]
        subtitle := StrReplace(subtitle, "&", "And")
        subtitle := StrReplace(subtitle, "-", " ")
        subtitle := ToUpperCamelCase(subtitle)
        
        index := index + 1
        
        while (index < parts.MaxIndex() and IsEmptyOrWhiteSpace(parts[index]))
            index := index + 1
            
        if (index <= parts.MaxIndex()) {
            author := GetAuthorship(parts[index])
            
            if (StrLen(author) > 0)
                subtitle := author . separator . subtitle
        }
        
        return subtitle
    }
    
    return ToUpperCamelCase(footer)
}

TogglePaneInExplorer(letter) {
    if WinActive("ahk_class CabinetWClass")
        SendInput !v%letter%
}

; http://www.autohotkey.com/board/topic/121208-windows-explorer-get-folder-path/
Explorer_GetSelection(hwnd = "") {
    WinGet, process, processName, % "ahk_id" hwnd := hwnd ? hwnd : WinExist("A")
    WinGetClass class, ahk_id %hwnd%
    StringLower, process, process
    
    if (process = "explorer.exe") {
        if (class ~= "Progman|WorkerW") {
            ControlGet, files, List, Selected Col1, SysListView321, ahk_class %class%
            Loop, Parse, files, `n, `r
                ToReturn .= A_Desktop "\" A_LoopField "`n"
        } else if (class ~= "(Cabinet|Explore)WClass") {
            for window in ComObjCreate("Shell.Application").Windows
                if (window.hwnd = hwnd)
                    sel := window.Document.SelectedItems
            for item in sel
                ToReturn .= item.path "`n"
        }
    }
    
    return Trim(ToReturn, "`n")
}

; http://www.autohotkey.com/board/topic/121208-windows-explorer-get-folder-path/
GetItemNamesFromCurrentExplorerWindow(hwnd = "") {
    hwnd := hwnd ? hwnd : WinExist("A")
    WinGet, process, ProcessName, ahk_id %hwnd%
    WinGetClass class, ahk_id %hwnd%
    StringLower, process, process
    
    if (process = "explorer.exe" and class ~= "(Cabinet|Explore)WClass") {
        for window in ComObjCreate("Shell.Application").Windows {
            if (window.hwnd = hwnd) {
                sel := window.Document.Folder.Items
            }
        }
    }
    
    return sel
}

GetLatestDatedItemName(items) {
    for item in items {
        path := item.path
        if (RegExMatch(path, "\d{4}_\d{2}_\d{2}(_\d{6})?(?=[^\\]*$)", match)) {
            str := match "`n"
        }
    }
    
    return str
}

GetLatestDatedItemNameInExplorerWindow() {
    return GetLatestDatedItemName(GetItemNamesFromCurrentExplorerWindow())
}

GetTopLogicalDiskId() {
    drive_type := 3
    query := "Select * FROM Win32_LogicalDisk WHERE DriveType = " . drive_type
    
    for disk in (ComObjGet("winmgmts:").ExecQuery(query)) {
        top_drive := disk.DeviceID
    }
    
    return top_drive
}

GetBatchMessage(list, singular, plural, singular_predicate, plural_predicate) {
    msg := ""
    
    if (list.MaxIndex() = 1) {
        msg := singular . list[1] . singular_predicate
    } else {
        msg := plural
        
        if (list.MaxIndex() = 2) {
            msg .= list[1] " and " list[2]
        } else {
            key := 1
            
            while (key < list.MaxIndex()) {
                msg .= list[key] ", "
                key := key + 1
            }
            
            msg .= "and " list[key]
        }
        
        msg .= plural_predicate
    }
    
    return msg
}

GetCloseAllMessage(processes) {
    return GetBatchMessage(processes, "Process: ", "Processes: ", " has been terminated.", " have been terminated.")
    
    ;; OLD VERSION
    ;; -----------
    ;
    ; for key in processes
    ;   msg .= processes[key] ".exe, "
    ;   
    ; if (processes.MaxIndex() > 1) {
    ;   msg := "Processes: " . msg
    ;   msg := RegExReplace(msg, ", $", " have been terminated.")
    ;   msg := RegExReplace(msg, ",(?=[^,]+$)", " and")
    ;   
    ;   if (RegExMatch(msg, ",[^,]+ and [^,]+$") > 0)
    ;       msg := RegExReplace(msg, " and (?=[^,]+$)", ", and ")
    ; } else {
    ;   msg := "Process: " . msg
    ;   msg := RegExReplace(msg, ", $", " has been terminated.")
    ; }
}

GetKillAllMessage(processes) {
    msg := "A terminate signal will be sent to the process"
    return GetBatchMessage(processes, msg . ": ", msg . "es: ", ".", ".")
}

GetRunAllScriptsMessage(scripts) {
    return GetBatchMessage(scripts, "Script: ", "Scripts: ", " is now running.", " are now running.")
}

CloseAll(processes, msgTitle := "", msg := "") {
    if (msgTitle <> "" and msg <> "") {
        MsgBox, 0, % msgTitle, % msg, 7
    }
    
    for key in processes
        Process, Close, % processes[key] ".exe"
}

KillAllProcesses(process_names, msgTitle := "", msg := "") {
    if (msgTitle <> "" and msg <> "") {
        MsgBox, 0, % msgTitle, % msg, 7
    }
    
    for key in process_names
        Run, % "taskkill /F /T /IM " . process_names[key]
}

LoadConfirmationDialog() {
    Gui, Destroy
    Gui, Add, Button, gGuiEscape, Confirm or Escape to close window
    Gui, Add, Button, w0 h0 Hidden Default, Cancel
    Gui, Show
}

ListHotkeys(use_confirmation_dialog) {
	if (use_confirmation_dialog) {
		Monitor.Block()
		ListHotkeys
		LoadConfirmationDialog()
	} else {
		ListHotkeys
	}
}

;;;;;;;;;;;;;;;;;;;
; --- Hotkeys --- ;
;;;;;;;;;;;;;;;;;;;

; Oh this? Just a little, *experiment*.
>!RCtrl::AppsKey
>^RAlt::AppsKey

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; --- Command Strings --- ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Temporarily disable this script
    
; Re-enable this script
    
; Terminate AutoHotkey and the expected compiled version of this script
    
; Kill all Web browser applications
    
; Display Help Message
    
; Toggle Preview Pane in Windows Explorer
    
; Toggle Details Pane in Windows Explorer
    
; Opens a date-select calendar, allowing the user to choose a date to replace this
; hotstring with
    
; Opens a list of title formats, allowing the user to choose one to replace this
; hotstring with
    
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; --- String Replacers --- ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Send keystrokes from clipboard
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Replace with the title-case version of the clipboard string
    
; Replace backslashes with slashes
    
; Replace slashes with backslashes
    
; Alter content on the clipboard
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Replace all tabs with spaces on the clipboard
    
    
    
    
    
    
    
; Replace hotstring
;;;;;;;;;;;;;;;;;;;

; Replace with the device ID of the top logical disk drive
    
; Replace with current date in standard "yyyy_MM_dd" format
    
; Replace with current date in pretty "d MMMM yyyy" format
    
; Replace with current time
    
; Replace with current date and time
    
; Replace with the latest datetime string occurring in
; the currently active explorer window
    
; Replace with a title-corrected string from the Clipboard
    
; Replace with current date and title string
    
; Replace with current date and time and title string
    
; Replace with current date and title string
    
; Replace with current date and time and title string
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; --- Replace With Last Weekday's Date --- ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    
    
    
    
    
    
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; --- Replace With Next Weekday's Date --- ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    
    
    
    
    
    
    
;;;;;;;;;;;;;;;;;;;;;;;
; --- Subroutines --- ;
;;;;;;;;;;;;;;;;;;;;;;;

; ShowCalendar
;;;;;;;;;;;;;;

ShowCalendar:
    Gui, Destroy
    Gui, Add, MonthCal, vMyCalendar
    Gui, Add, Button, w100 x+m gPrintDate, Print && &Go
    Gui, Add, Button, w100 gCopyDate, &Copy To Clipboard
    Gui, Add, Button, w100 gGuiEscape, Ca&ncel
    Gui, Add, Text, cgreen w200 xs vForVendetta
    Gui, Add, Button, w0 h0 Hidden Default, DefaultCalendar
    Gui, Show,, GetDateCalendar
    Hotkey, ~F5, ResetCalendar
    Hotkey, ~F5,, On
    Hotkey, ~^p, PrintDate
    Hotkey, ~^p,, On
    Hotkey, ~^c, CopyDate
    Hotkey, ~^c,, On
    Return
    
ResetCalendar:
    Gui, Destroy
    Gosub, ShowCalendar
    Return
    
ButtonDefaultCalendar:
    Gosub, PrintDate
    Return
    
ButtonCancel:
	Gosub, GuiEscape
	Return
	
PrintDate:
    Gui, Submit
    FormatTime dateString, %MyCalendar%, %__date_format%
    SendInput %dateString%
    Gosub, GuiEscape
    Return
    
CopyDate:
    Gui, Submit, NoHide
    FormatTime dateString, %MyCalendar%, %__date_format%
    Clipboard := dateString
    GuiControl,, ForVendetta, % "Copied to Clipboard:" . __text_space . Clipboard
    Return
    
; ShowTitleFormatListView
;;;;;;;;;;;;;;;;;;;;;;;;;

ShowTitleFormatListView:
    Gui, Destroy
    Gui, Add, ListView, w500 -Multi -ReadOnly, Press Enter to select a format.
    Gosub, SetList
    Gui, Add, Button, w100 gPrintTitle, Print && &Go
    Gui, Add, Button, w100 x+m yp gCopyTitle, &Copy To Clipboard
    Gui, Add, Button, w100 x+m yp gResetList, &Reset
    Gui, Add, Button, w100 x+m yp gGuiEscape, Ca&ncel
    Gui, Add, Text, cgreen w500 r2 xs +Wrap vForVendetta
    Gui, Add, Button, w0 h0 Hidden Default, DefaultListView
    Gui, Show,, GetTitleFormatList
	
	__mapped_keys := 1
	
    Hotkey, ~F5, ResetList
    Hotkey, ~F5,, On
    Hotkey, ~^p, PrintTitle
    Hotkey, ~^p,, On
    Hotkey, ~^c, CopyTitle
    Hotkey, ~^c,, On
    Return
    
SetList:
    LV_Add("", GetTitle(GetStdDate(), Clipboard, "_", __secnd_separator))
    LV_Add("", GetTitle(GetDateAndTime(), Clipboard, "_", __secnd_separator))
    LV_Add("", GetTitle(GetStdDate(), Clipboard, "_-_", __secnd_separator))
    LV_Add("", GetTitle(GetDateAndTime(), Clipboard, "_-_", __secnd_separator))
    Return
    
ResetList:
    LV_Delete()
    Gosub, SetList
    FormatTime dateString,, HH:mm:ss%__text_space%dd/MM/yyyy
    GuiControl,, ForVendetta, % "Last reset at:" . __text_space . dateString
    Return
    
ButtonDefaultListView:
    Gosub, PrintTitle
    Return
    
PrintTitle:
    GuiControlGet, FocusedControl, Focus
    
    If (FocusedControl <> SysListView321)
        Return
        
    RowNumber := LV_GetNext(0, "Focused")
    
    If (RowNumber > 0) {
        LV_GetText(RowText, RowNumber)
        Gui, Submit
        SendInput % RowText
    }
    
    Gosub, GuiEscape
    Return
    
CopyTitle:
    GuiControlGet, FocusedControl, Focus
    
    If (FocusedControl <> SysListView321)
        Return
        
    RowNumber := LV_GetNext(0, "Focused")
    
    If (RowNumber > 0) {
        LV_GetText(RowText, RowNumber)
        Gui, Submit, NoHide
        Clipboard := RowText
        GuiControl,, ForVendetta, % "Copied to Clipboard:" . __text_space . Clipboard
    }
    
    Return
    
; Other Subroutines
;;;;;;;;;;;;;;;;;;;

UnmapKeys:
	if (__mapped_keys) {
		Hotkey, ~F5, Off
		Hotkey, ~^p, Off
		Hotkey, ~^c, Off
		__mapped_keys := 1
	}
	
    Return
    
GuiEscape:
    Gui, Destroy
    Gosub, UnmapKeys
	Monitor.Unblock()
    Return


; ***********************
; * --- DEFINITIONS --- *
; ***********************

function_0000() {
    global
    return Monitor.Disable()
}

function_0001() {
    global
    return Monitor.Enable()
}

function_0002() {
    global
    master_proc := Monitor.MasterProcessName()  
    processes := ["AutoHotkey.exe", master_proc]
    msg := GetKillAllMessage(processes)
    return Monitor.Override("KillAllProcesses", processes, master_proc, msg)
}

function_0003() {
    global
    msg := GetKillAllMessage(processes)
    return Monitor.Override("KillAllProcesses", __browser_process_names)
}

function_0004() {
    global
    return Monitor.Override("DisplayHelpMessage")
}

function_0005() {
    global
    return Monitor.Override("TogglePaneInExplorer", "p")
}

function_0006() {
    global
    return Monitor.Override("TogglePaneInExplorer", "d")
}

function_0007() {
    global
	Monitor.Block()
    return Monitor.VerifyAndGo("ShowCalendar")
}

function_0008() {
    global
	Monitor.Block()
    return Monitor.VerifyAndGo("ShowTitleFormatListView")
}

function_0009() {
    global
    return Monitor.Override("ListHotkeys", !A_ThisHotkey)
}

function_0010() {
    global
    return Monitor.Run("ToTitleCase", Clipboard)
}

function_0011() {
    global
    return Monitor.Run("ToUnixString", Clipboard)
}

function_0012() {
    global
    return Monitor.Run("ToDosString", Clipboard)
}

function_0013() {
    global
    return Monitor.Clip("ReplaceTabsWithSpaces", Clipboard)
}

function_0014() {
    global
    return Monitor.Override("PasteBlockText", Clipboard, __tab_size, __note_width)
}

function_0015() {
    global
    return Monitor.Run("PasteBlockText", Clipboard, 4, __note_width)
}

function_0016() {
    global
    return Monitor.Run("PasteBlockText", Clipboard, 8, __note_width)
}

function_0017() {
    global
    return Monitor.Override("PasteCondensedBlockText", Clipboard, __tab_size, __note_width)
}

function_0018() {
    global
    return Monitor.Run("PasteCondensedBlockText", Clipboard, 4, __note_width)
}

function_0019() {
    global
    return Monitor.Run("PasteCondensedBlockText", Clipboard, 8, __note_width)
}

function_0020() {
    global
    return Monitor.Run("GetTopLogicalDiskId")
}

function_0021() {
    global
    return Monitor.Run("GetStdDate")
}

function_0022() {
    global
    return Monitor.Run("GetPrettyDate")
}

function_0023() {
    global
    return Monitor.Run("GetTime")
}

function_0024() {
    global
    return Monitor.Run("GetDateAndTime")
}

function_0025() {
    global
    return Monitor.Run("GetLatestDatedItemNameInExplorerWindow")
}

function_0026() {
    global
    ; Run("ToUpperCamelCase", Clipboard)
    return Monitor.Run("GetSubtitle", Clipboard, __secnd_separator)
}

function_0027() {
    global
    return Monitor.Run("GetTitle", GetStdDate(), Clipboard, "_", __secnd_separator)
}

function_0028() {
    global
    return Monitor.Run("GetTitle", GetDateAndTime(), Clipboard, "_", __secnd_separator)
}

function_0029() {
    global
    return Monitor.Run("GetTitle", GetStdDate(), Clipboard, "_-_", __secnd_separator)
}

function_0030() {
    global
    return Monitor.Run("GetTitle", GetDateAndTime(), Clipboard, "_-_", __secnd_separator)
}

function_0031() {
    global
    return Monitor.Run("GetLastDate", 1)
}

function_0032() {
    global
    return Monitor.Run("GetLastDate", 2)
}

function_0033() {
    global
    return Monitor.Run("GetLastDate", 3)
}

function_0034() {
    global
    return Monitor.Run("GetLastDate", 4)
}

function_0035() {
    global
    return Monitor.Run("GetLastDate", 5)
}

function_0036() {
    global
    return Monitor.Run("GetLastDate", 6)
}

function_0037() {
    global
    return Monitor.Run("GetLastDate", 7)
}

function_0038() {
    global
    return Monitor.Run("GetNextDate", 1)
}

function_0039() {
    global
    return Monitor.Run("GetNextDate", 2)
}

function_0040() {
    global
    return Monitor.Run("GetNextDate", 3)
}

function_0041() {
    global
    return Monitor.Run("GetNextDate", 4)
}

function_0042() {
    global
    return Monitor.Run("GetNextDate", 5)
}

function_0043() {
    global
    return Monitor.Run("GetNextDate", 6)
}

function_0044() {
    global
    return Monitor.Run("GetNextDate", 7)
}


; **********************
; * --- HOTSTRINGS --- *
; **********************

::;stop;::
::;start;::
::;kill;::
::;panic;::
::;help;::
::;ppane;::
::;preview;::
::;dpane;::
::;details;::
::;calendar;::
::;formats;::
::;list;::
:*:;t;::
:*:;titlecase;::
:*:;tounix;::
:*:;todos;::
:*:;tab2space;::
:*:;block;::
:*:;block_tab4;::
:*:;block_tab8;::
:*:;condense;::
:*:;condense_tab4;::
:*:;condense_tab8;::
:*:;top;::
:*:;date;::
:*:;prettydate;::
:*:;time;::
:*:;datetime;::
:*:;last;::
:*:;title;::
:*:;d_title;::
:*:;dt_title;::
:*:;d_-_title;::
:*:;dt_-_title;::
:*:;last_Sun;::
:*:;lSun;::
:*:;last_Mon;::
:*:;lMon;::
:*:;last_Tue;::
:*:;lTue;::
:*:;last_Wed;::
:*:;lWed;::
:*:;last_Thu;::
:*:;lThu;::
:*:;last_Fri;::
:*:;lFri;::
:*:;last_Sat;::
:*:;lSat;::
:*:;next_Sun;::
:*:;nSun;::
:*:;next_Mon;::
:*:;nMon;::
:*:;next_Tue;::
:*:;nTue;::
:*:;next_Wed;::
:*:;nWed;::
:*:;next_Thu;::
:*:;nThu;::
:*:;next_Fri;::
:*:;nFri;::
:*:;next_Sat;::
:*:;nSat;::
    Call(Trim(Monitor.GetHotkeyName(A_ThisHotkey), ";"))
    return
