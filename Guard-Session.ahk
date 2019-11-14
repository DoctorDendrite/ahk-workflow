
__timeout := 2000
__stop_combo := "^c"

Main() {
	global
	
	MsgBox,,, Session Guard on., 7
	CoordMode, Mouse, Screen
	Hotkey, %__stop_combo%, StopScript
	
	loop {
		Sleep, __timeout
		MouseGetPos, x, y
		MouseMove, % x + 5, % y + 5
		MouseMove, % x, % y
	}
}

Main()
Return

StopScript:
	MsgBox,,, Session Guard off., 7
	ExitApp
	