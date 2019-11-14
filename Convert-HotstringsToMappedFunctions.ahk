

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; --- Parameters & Constants --- ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ADD_ALL := 1
INCLUDE_ORIGINAL := 0
SINGLE_INSTANCE_FORCE := 1
PERSISTENT := 1
RETURN_LAST_LINE := 1
ADD_MAIN := 1
ADD_HOTSTRINGS := 1

for index, param in A_Args {
	StringUpper, what, param
	
	if      (what = "--ALLCONTENT" or what = "--ALL" or what = "-A")
		ADD_ALL := 1
	else if (what = "--INCLUDEORIGINAL" or what = "--INCLUDE" or what = "-I")
		INCLUDE_ORIGINAL := 1
	else if (what = "--SINGLEINSTANCE" or what = "--SINGLE" or what = "-S")
		SINGLE_INSTANCE_FORCE := 1
	else if (what = "--PERSISTENT" or what = "-P")
		PERSISTENT := 1
	else if (what = "--RETURNLASTLINE" or what = "-R")
		RETURN_LAST_LINE := 1
	else if (what = "--MAINENTRY" or what = "--MAIN" or what = "-M")
		ADD_MAIN := 1
	else if (what = "--HOTSTRINGS" or what = "-H")
		ADD_HOTSTRINGS := 1
	else
		if (StrLen(INFILE) > 0)
			OUTFILE := param
		else
			INFILE := param
}

INDENT := "    "
MAP_NAME := "__names"
SUFFIX := "_Map"
OUTFILE := (StrLen(OUTFILE) = 0) ? GetOutFileName(INFILE, SUFFIX) : OUTFILE

MAIN_ENTRY_STRING =
(
Call(script_param) {
	global
	Func(__MAP_NAME__[script_param]).Call()
}

for index, script_param in A_Args {
	if (StrLen(script_param) > 0) {
		Call(script_param)
	}
	
	Monitor.Exit()
}
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; --- FileIterator Class --- ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IsWhiteSpace(line) {
	return line ~= "^\s*$"
}

class FileIterator {
	static __INVALID_FILENAME := "<Null>"
	
	__filename := __INVALID_FILENAME
	__position := 0
	__current := ""
	__any := 1
	
	InstanceMethod() {
		if (this.__filename = FileIterator.__INVALID_FILENAME)
			throw Exception("OBJECT NOT INITIALIZED")
	}
	
	__New(filename) {
		this.__filename := filename
	}
	
	Filename() {
		FileIterator.InstanceMethod()
		return this.__filename
	}
	
	Next(ByRef line) {
		FileIterator.InstanceMethod()
		this.__position := this.__position + 1
		FileReadLine, what, % this.__filename, % this.__position
		this.__current := what
		this.__any := ErrorLevel = 0
		
		if (this.__any)
			line := this.__current
		
		return this.__any
	}
	
	NextNonWhiteSpace(ByRef line) {
		while (this.Next(line) and IsWhiteSpace(line)) {
			; Do nothing.
		}
		
		return this.__any
	}
	
	GoBack() {
		FileIterator.InstanceMethod()
		if (this.__position > 1) {
			this.__position := this.__position - 1
		}
	}
	
	Current() {
		FileIterator.InstanceMethod()
		return this.__current
	}
	
	Any() {
		FileIterator.InstanceMethod()
		return this.__any
	}
	
	Copy() {
		other := New FileIterator(this.__filename)
		other.__position := this.__position
		other.__current := this.__current
		other.__any := this.__any
		return other
	}
}


;;;;;;;;;;;;;;;;;;;;;
; --- Functions --- ;
;;;;;;;;;;;;;;;;;;;;;

GetShortName(filename) {
	return RegExReplace(filename, ".*\\")
}

GetOutFileName(filename, suffix) {
	return A_ScriptDir . "\" . RegExReplace(GetShortName(filename), "\.ahk$", suffix . ".ahk")
}

HotstringSequence(line, ByRef out) {
	position := RegExMatch(line, "O)^:[^:]*:;(?<NAME>[^:]+);:[^:]*:", match)
	out := match.Value("NAME")
	return position > 0
}

ReturnSequence(line) {
	return line ~= "^\s*return(\W|$)"
}

FileOutLine(line, filename) {
	FileAppend, %line%`r`n, %filename%, UTF-8
}

ListToString(list, delim := ", ") {
	str := ""
	index := 1
	
	while (index < list.MaxIndex()) {
		str .= list[index] . delim
		index := index + 1
	}
	
	if (list.MaxIndex() > 0) {
		str .= list[index]
	}
	
	return str
}

Any(list) {
	return list.MaxIndex() > 0
}

GetIndex(number) {
	return SubStr("0000" . number, -3)
}

GetFunctionName(number) {
	return "function_" . GetIndex(number)
}

GetDefinition(commands, name) {
	global
	str := name . "() {`r`n"
	str .= INDENT . "global`r`n"
	str .= ListToString(commands, "`r`n")
	str .= "`r`n}"
	return str
}

GetGlobalVariables(ByRef it) {
	globals := []
	cit := it.Copy()
	
	cit.GoBack()
	cit.GoBack()
	
	if (cit.Next(line) and IsCommentBarLine(line)) {
		globals.Push(line)
		
		while (cit.Next(line) and !IsCommentBarLine(line)) {
			globals.Push(line)
		}
		
		if (IsCommentBarLine(line)) {
			globals.Push(line)
		}
	}
	
	while (cit.Next(line) and !IsCommentBarLine(line)) {
		globals.Push(line)
	}
	
	it := cit.Copy()
	return globals
}

GetAddToMapCommand(map_name, hotstring, function_name) {
	return map_name . "[""" . hotstring . """] := """ . "" . function_name . """"
}

GetTestString(map_name, hotstring_name) {
	return "Func(" . map_name . "[""" . hotstring_name . """]).Call()"
}

GetIncludeString(filename) {
	return "#Include %A_ScriptDir%\" . GetShortName(filename)
}

GetMainEntryString(map_name) {
	global
	return StrReplace(MAIN_ENTRY_STRING, "__MAP_NAME__", map_name)
}

IsCommentBarLine(line) {
	return line ~= "^\s*`;`;+\s*$"
}

IsHeader(line) {
	_isHeader := line ~= "^\s*\#"
	
	; ; TEST
	; ; ----
	; what := (_isHeader) ? 1 : 0
	; MsgBox, % "Line: [" line "] IsHeader: [" what "]"
	
	return _isHeader
}

IsUnnecessaryDirective(line) {
	_isUnnecessaryDirective := line ~= "^\s*(\#SingleInstance|\#Persistent)"
	
	; ; TEST
	; ; ----
	; what := (_isUnnecessaryDirective) ? 1 : 0
	; MsgBox, % "Line: [" line "] IsUnnecessaryDirective: [" what "]"
	
	return _isUnnecessaryDirective
}

SubtractWhiteSpace(lines, ByRef start, ByRef end) {
	start := 1
	while (start <= lines.MaxIndex() and IsWhiteSpace(lines[start])) {
		start := start + 1
	}
	
	end := lines.MaxIndex()
	while (end >= 1 and IsWhiteSpace(lines[end])) {
		end := end - 1
	}
}


;;;;;;;;;;;;;;;;;;;;;;
; --- Main Entry --- ;
;;;;;;;;;;;;;;;;;;;;;;

Main(infile, outfile) {
	global
	it := New FileIterator(infile)
	has_header := 0
	
	if (INCLUDE_ORIGINAL) {
		has_header := 1
		FileOutLine(GetIncludeString(infile), outfile)
	}
	
	if (SINGLE_INSTANCE_FORCE) {
		has_header := 1
		FileOutLine("#SingleInstance Force", outfile)
	}
	
	if (PERSISTENT) {
		has_header := 1
		FileOutLine("#Persistent", outfile)
	}
	
	while (it.NextNonWhiteSpace(line) and IsHeader(line)) {
		if (!IsUnnecessaryDirective(line)) {
			has_header := 1
			FileOutLine(line, outfile)
		}
	}
	
	if (has_header) {
		FileOutLine("`r`n", outfile)
	}
	
	map := {}
	hotstrings_per_def := []
	hotstring_lines := []
	hotstring_names := []
	commands := []
	definitions := []
	other := []
	globals := []
	number := 0
	
	it.GoBack()
	
	while (it.Next(line)) {
	
		if (line ~= "i)--- Global Variables ---") {
			glob := GetGlobalVariables(it)
			line := it.Current()
		}
		
		if (HotstringSequence(line, out)) {
			hotstrings_per_def.Push(out)
			hotstring_names.Push(out)
			hotstring_lines.Push(line)
		} else if (Any(hotstrings_per_def)) {
			if (ReturnSequence(line)) {
				if (RETURN_LAST_LINE) {
					last := line . " " . RegExReplace(commands[commands.MaxIndex()], "^\s+")
					commands[commands.MaxIndex()] := last
				} else {
					commands.Push(line)
				}
				
				function_name := GetFunctionName(number)
				function_def := GetDefinition(commands, function_name)
				
				for index, hotstring in hotstrings_per_def {
					map[hotstring] := function_name
					; FileOutLine(GetAddToMapCommand(MAP_NAME, hotstring, function_name), outfile)
				}
				
				definitions.Push(function_def)
				hotstrings_per_def := []
				commands := []
				number := number + 1
			} else {
				commands.Push(line)
			}
		} else if (ADD_ALL) {
			other.Push(line)
		}
	}
	
	FileOutLine("`; **********************", outfile)
	FileOutLine("`; * --- DICTIONARY --- *", outfile)
	FileOutLine("`; **********************`r`n", outfile)
	
	; I actually don't necessarily want this line, since I plan on compiling many files together.
	; 
	;    2019_10_25: I disagree.
	
	FileOutLine("if (!" MAP_NAME ") {`r`n`t" MAP_NAME ":= {}`r`n}", outfile)
	
	for index, hotstring in hotstring_names {
		FileOutLine(GetAddToMapCommand(MAP_NAME, hotstring, map[hotstring]), outfile)
	}
	
	if (ADD_ALL and Any(globals)) {
		FileOutLine("`r`n", outfile)
		
		SubtractWhiteSpace(globals, index, max_index)
		
		while (index <= max_index) {
			FileOutLine(globals[index], outfile)
			index := index + 1
		}
	}
	
	if (ADD_MAIN) {
		FileOutLine("`r`n", outfile)
		FileOutLine("; **********************", outfile)
		FileOutLine("; * --- MAIN ENTRY --- *", outfile)
		FileOutLine("; **********************`r`n", outfile)
		FileOutLine(GetMainEntryString(MAP_NAME), outfile)
	}
	
	if (ADD_ALL and Any(other)) {
		FileOutLine("`r`n", outfile)
		FileOutLine("; *******************", outfile)
		FileOutLine("; * --- CONTENT --- *", outfile)
		FileOutLine("; *******************`r`n", outfile)
		
		SubtractWhiteSpace(other, index, max_index)
		
		while (index <= max_index) {
			FileOutLine(other[index], outfile)
			index := index + 1
		}
	}
	
	FileOutLine("`r`n", outfile)
	FileOutLine("; ***********************", outfile)
	FileOutLine("; * --- DEFINITIONS --- *", outfile)
	FileOutLine("; ***********************", outfile)
	
	for index, definition in definitions {
		FileOutLine("", outfile)
		FileOutLine(definition, outfile)
	}
	
	if (ADD_HOTSTRINGS) {
		FileOutLine("`r`n", outfile)
		FileOutLine("; **********************", outfile)
		FileOutLine("; * --- HOTSTRINGS --- *", outfile)
		FileOutLine("; **********************`r`n", outfile)
		
		for index, line in hotstring_lines {
			FileOutLine(line, outfile)
		}
		
		; FileOutLine(INDENT . GetMainCallString(MAP_NAME, "Trim(A_ThisHotkey, ""`;"")"), outfile)
		; FileOutLine(INDENT . "return", outfile)
		
		MAIN_CALL_STRING := INDENT "Call(Trim(Monitor.GetHotkeyName(A_ThisHotkey), ""`;""))`r`n"
		MAIN_CALL_STRING .= INDENT "return"
		FileOutLine(MAIN_CALL_STRING, outfile)
	}
}

Main(INFILE, OUTFILE)
