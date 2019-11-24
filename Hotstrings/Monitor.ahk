#Persistent
#SingleInstance Force

; Source:
;    https://www.autohotkey.com/boards/viewtopic.php?t=5933
; 
; Accessed:
;    2019_10_12

class Monitor
{
    static __MASTER_PROCESS := "Master.exe"
    static __scripts_enabled := 1
    static __mutex_lock := 0
    
    MasterProcessName() {
        return Monitor.__MASTER_PROCESS
    }
    
    Available() {
        return Monitor.__scripts_enabled
    }
    
    SetAvailability(decision, message) {
        Monitor.__scripts_enabled := decision
        MsgBox % message
    }
    
    Disable() {
        Monitor.SetAvailability(0, "Hotstrings have been disabled.")
    }
    
    Enable() {
        Monitor.SetAvailability(1, "Hotstrings have been enabled.")
    }
    
    VerifyAndGo(subroutineName) {
        hotstring := Monitor.GetThisHotkeyName()
        
        if (StrLen(hotstring) = 0 or Monitor.__scripts_enabled = 1)
            Gosub, %subroutineName%
    }
    
    VerifyAndInvoke(functionName, hotstring, args*) {
        if (Monitor.__scripts_enabled = 1)
            return Func(functionName).Bind(args*).Call()
        return %hotstring%
    }
    
    Invoke(functionName, args*) {
        return Func(functionName).Bind(args*).Call()
    }
    
    VerifyAndSendAsKeystroke(str, alt := "") {
        if (StrLen(str) > 0)
            SendInput %str%
        else if (StrLen(alt) > 0)
            SendInput %alt%
    }
    
    SendToStdOut(str) {
        OutputDebug, %str%
    }
    
    VerifyAndSendToClipboard(str, alt := "") {
        if (StrLen(str) > 0)
            Clipboard := str
        else if (StrLen(alt) > 0)
            SendInput %alt%
    }
    
    SendToClipboard(str) {
        if (StrLen(str) > 0)
            Clipboard := str
    }
    
    GetHotkeyName(hotkey) {
        return RegExReplace(hotkey, "^:[^:]*:")
    }
    
    GetThisHotkeyName() {
        return Monitor.GetHotkeyName(A_ThisHotkey)
    }
    
    RunWithReplacement(functionName, hotstring, replacement, args*) {
        if (StrLen(hotstring) > 0) {
            output := Monitor.VerifyAndInvoke(functionName, hotstring, args*)
            Monitor.VerifyAndSendAsKeystroke(output, replacement)
        } else {
            output := Monitor.Invoke(functionName, args*)
            Monitor.SendToStdOut(output)
            Monitor.SendToClipboard(output)
        }
    }
    
    Run(functionName, args*) {
        hotstring := Monitor.GetThisHotkeyName()
        Monitor.RunWithReplacement(functionName, hotstring, hotstring, args*)
    }
    
    Override(functionName, args*) {
        hotstring := Monitor.GetThisHotkeyName()
        Monitor.RunWithReplacement(functionName, hotstring, "", args*)
    }
    
    Send(str) {
        hotstring := Monitor.GetThisHotkeyName()
        
        if (StrLen(hotstring) > 0) {
            Monitor.VerifyAndSendAsKeystroke(str, hotstring)
        } else {
            Monitor.SendToStdOut(str)
            Monitor.SendToClipboard(str)
        }
    }
    
    ToUnicode(str) {
        pack := "0x00000"
        RegExMatch(str, "(?<=U\+)\w+", match)
        out := SubStr(pack, 1, StrLen(pack) - StrLen(match)) . match
        return Chr(out)
    }
    
    SendUnicode(str) {
        hotstring := Monitor.GetThisHotkeyName()
        
        if (StrLen(hotstring) > 0) {
            Monitor.VerifyAndSendAsKeystroke(str, hotstring)
        } else {
            output := Monitor.ToUnicode(str)
            Monitor.SendToStdOut(output)
            Monitor.SendToClipboard(output)
        }
    }
    
    Clip(functionName, args*) {
        hotstring := Monitor.GetThisHotkeyName()
        
        if (StrLen(hotstring) > 0) {
            output := Monitor.VerifyAndInvoke(functionName, "", args*)
            Monitor.VerifyAndSendToClipboard(output, hotstring)
        } else {
            output := Monitor.Invoke(functionName, args*)
            Monitor.SendToClipboard(output)
        }
    }
    
    Block() {
        Monitor.__mutex_lock := 1
    }
    
    Unblock() {
        Monitor.__mutex_lock := 0
    }
    
    Exit() {
        while (Monitor.__mutex_lock = 1) {
            ; Do nothing
        }
        
        ExitApp
    }
}
