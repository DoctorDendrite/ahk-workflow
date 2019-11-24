

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
    
        ADD_ALL := !(ADD_ALL)
        
    else if (what = "--INCLUDEORIGINAL" or what = "--INCLUDE" or what = "-I")
    
        INCLUDE_ORIGINAL := !(INCLUDE_ORIGINAL)
        
    else if (what = "--SINGLEINSTANCE" or what = "--SINGLE" or what = "-S")
    
        SINGLE_INSTANCE_FORCE := !(SINGLE_INSTANCE_FORCE)
        
    else if (what = "--PERSISTENT" or what = "-P")
    
        PERSISTENT := !(PERSISTENT)
        
    else if (what = "--RETURNLASTLINE" or what = "-R")
    
        RETURN_LAST_LINE := !(RETURN_LAST_LINE)
        
    else if (what = "--MAINENTRY" or what = "--MAIN" or what = "-M")

        ADD_MAIN := !(ADD_MAIN)

    else if (what = "--HOTSTRINGS" or what = "-H")

        ADD_HOTSTRINGS := !(ADD_HOTSTRINGS)

    else
        if (StrLen(INFILE) > 0)
            OUTFILE := param
        else
            INFILE := param
}

INDENT := "    "
MAP_NAME := "__names"
HELP_NAME := "__help"
SUFFIX := "_Map"
OUTFILE := (StrLen(OUTFILE) = 0) ? GetOutFileName(INFILE, SUFFIX) : OUTFILE

MAIN_ENTRY_STRING =
(
Call(key) {
    global
    Func(%MAP_NAME%[key]).Call()
}

Show(command, key) {
    global
    StringUpper, command, command
    
    if (command = "HELP") {
        MsgBox, `% %HELP_NAME%[key]
    }
}

Main() {
    params := []
    
    for index, param in A_Args {
        if (StrLen(param) > 0) {
            params.Push(param)
        }
    }
    
    if (params.MaxIndex() = 1) {
        Call(params[1])
        Monitor.Exit()
    } else if (params.MaxIndex() > 1) {
        Show(params[1], params[2])
        Monitor.Exit()
    }
}

Main()
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
    __file := __INVALID_FILENAME
    __current := ""
    
    InstanceMethod() {
        if (this.__filename = FileIterator.__INVALID_FILENAME)
            throw Exception("OBJECT NOT INITIALIZED")
    }
    
    __New(filename) {
        this.__filename := filename
        this.__file := FileOpen(filename, "r-d `n")
        
        if (!IsObject(this.__file)) {
            throw Exception("FILE OBJECT NOT INITIALIZED")
        }
    }
    
    __Delete() {
        this.Close()
    }
    
    Filename() {
        FileIterator.InstanceMethod()
        return this.__filename
    }
    
    Next(ByRef line) {
        FileIterator.InstanceMethod()
        this.__current := RTrim(this.__file.ReadLine(), "`r`n")
        
        if (this.Any())
            line := this.__current
            
        return this.Any()
    }
    
    NextNonWhiteSpace(ByRef line) {
        while (this.Next(line) and IsWhiteSpace(line)) {  ; calls `InstanceMethod`
            ; Do nothing.
        }
        
        return this.Any()
    }
    
    Current() {
        FileIterator.InstanceMethod()
        return this.__current
    }
    
    Any() {
        FileIterator.InstanceMethod()
        return !this.__file.AtEOF
    }
    
    Close() {
        FileIterator.InstanceMethod()
        return this.__file.Close()
    }
}


;;;;;;;;;;;;;;;;;;;;;;;
; --- Table Class --- ;
;;;;;;;;;;;;;;;;;;;;;;;

class Table {
    static __INVALID_OBJECT_VALUE := "<Null>"
    
    __table := __INVALID_OBJECT_VALUE
    __keys := __INVALID_OBJECT_VALUE
    
    InstanceMethod() {
        if (this.__filename = Table.__INVALID_OBJECT_VALUE)
            throw Exception("OBJECT NOT INITIALIZED")
    }
    
    __New() {
        this.__table := {}
        this.__keys := []
        return this
    }
    
    Get(section) {
        Table.InstanceMethod()
        return this.__table[section]
    }
    
    Add(section, content) {
        Table.InstanceMethod()
        
        if (!this.__table[section]) {
            this.__table[section] := []
            this.__keys.Push(section)
        }
        
        if (IsObject(content)) {
            for index, line in content {
                this.__table[section].Push(line)
            }
        } else {
            this.__table[section].Push(content)
        }
        
        return this
    }
    
    Remove(section) {
        Table.InstanceMethod()
        lines := this.__table.Delete(section)
        
        index := 1
        while (index <= this.__keys.MaxIndex() and this.__keys[index] != section) {
            index := index + 1
        }
        
        if (index <= this.__keys.MaxIndex()) {
            this.__keys.RemoveAt(index)
        }
        
        return lines
    }
    
    Keys() {
        Table.InstanceMethod()
        return this.__keys
    }
    
    MaxIndex() {
        Table.InstanceMethod()
        return this.__keys.MaxIndex()
    }
    
    Any() {
        Table.InstanceMethod()
        return this.__keys.MaxIndex() > 0
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

HelpSequence(line, ByRef out) {
    position := RegExMatch(line, "O)^\s*;\s*(?<TYPE>\w+):", match)
    out := match.Value("TYPE")
    return position > 0
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

GetAddToMapCommand(map_name, hotstring, function_name) {
    return map_name . "[""" . hotstring . """] := """ . "" . function_name . """"
}

GetTestString(map_name, hotstring_name) {
    return "Func(" . map_name . "[""" . hotstring_name . """]).Call()"
}

GetIncludeString(filename) {
    return "#Include %A_ScriptDir%\" . GetShortName(filename)
}

GetMainEntryString() {
    global
    str := MAIN_ENTRY_STRING
    str := StrReplace(str, "__MAP_NAME__", MAP_NAME)
    str := StrReplace(str, "__HELP_NAME__", HELP_NAME)
    return str
}

IsCommentLine(line) {
    return line ~= "^\s*`;"
}

IsCommentBarLine(line) {
    return line ~= "^\s*`;`;+\s*$"
}

IsHeader(line) {
    return line ~= "^\s*\#"
}

IsUnnecessaryDirective(line) {
    return line ~= "^\s*(\#SingleInstance|\#Persistent)"
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

GetSectionHeading(ByRef it, ByRef str, ByRef lines) {
    lines := []
    lines.Push(it.Current())
    
    it.Next(line)
    lines.Push(it.Current())
    position := RegExMatch(it.Current(), "O)--- (?<NAME>.+) ---", match)
    
    if (position > 0) {
        str := match.Value("NAME")
        StringUpper, str, str
        it.Next(line)
        lines.Push(it.Current())
    }
    
    return position
}

GetDocString(it) {
    str := ""
    line := it.Current()
    
    while (it.Any() and IsCommentLine(line)) {
        line := RegExReplace(line, "^\s*`;\s*|\s*$", "")
        line := RegExReplace(line, """", """""")
        str := (str = "") ? line : str " " line
        it.Next(line)
    }
    
    return str
}


;;;;;;;;;;;;;;;;;;;;;;
; --- Main Entry --- ;
;;;;;;;;;;;;;;;;;;;;;;

Main(infile, outfile) {
    global
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
    
    it := New FileIterator(infile)
    
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
    help := {}
    hotstrings_per_def := []
    hotstring_lines := []
    hotstring_names := []
    commands := []
    definitions := []
    other := []
    number := 0
    help_str := ""
    
    sections := New Table
    
    while (it.Any()) {
        if (IsCommentBarLine(line) and GetSectionHeading(it, section_heading, lines) > 0) {
        
            for index, line in lines {
                sections.Add(section_heading, line)
            }
            
            it.Next(line)
            
        } else if (HelpSequence(line, out)) {
        
            help_str := GetDocString(it)
            line := it.Current()
            
        } else if (HotstringSequence(line, out)) {
        
            hotstrings_per_def.Push(out)
            hotstring_names.Push(out)
            hotstring_lines.Push(line)
            help[out] := help_str
            it.Next(line)
            
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
                }
                
                definitions.Push(function_def)
                hotstrings_per_def := []
                commands := []
                number := number + 1
            } else {
                commands.Push(line)
            }
            
            it.Next(line)
            
        } else if (ADD_ALL) {
        
            sections.Add(section_heading, line)
            it.Next(line)
        }
    }
    
    FileOutLine("`; **********************", outfile)
    FileOutLine("`; * --- DICTIONARY --- *", outfile)
    FileOutLine("`; **********************`r`n", outfile)
    
    ; I actually don't necessarily want this line, since I plan on compiling many files together.
    ; 
    ;    2019_10_25: I disagree.
    
    FileOutLine("if (!" MAP_NAME ") {`r`n`t" MAP_NAME ":= {}`r`n}", outfile)
    FileOutLine("if (!" HELP_NAME ") {`r`n`t" HELP_NAME ":= {}`r`n}", outfile)
    
    for index, hotstring in hotstring_names {
        FileOutLine(GetAddToMapCommand(MAP_NAME, hotstring, map[hotstring]), outfile)
    }
    
    for index, hotstring in hotstring_names {
        FileOutLine(GetAddToMapCommand(HELP_NAME, hotstring, help[hotstring]), outfile)
    }
    
    if (ADD_ALL) {
        FileOutLine("`r`n", outfile)
        
        for index, line in sections.Get("GLOBAL VARIABLES") {
            FileOutLine(line, outfile)
        }
        
        sections.Remove("GLOBAL VARIABLES")
    }
    
    if (ADD_MAIN) {
        FileOutLine("`r`n", outfile)
        FileOutLine("; **********************", outfile)
        FileOutLine("; * --- MAIN ENTRY --- *", outfile)
        FileOutLine("; **********************`r`n", outfile)
        FileOutLine(MAIN_ENTRY_STRING, outfile)
    }
    
    if (ADD_ALL and sections.Any()) {
        FileOutLine("`r`n", outfile)
        FileOutLine("; *******************", outfile)
        FileOutLine("; * --- CONTENT --- *", outfile)
        FileOutLine("; *******************`r`n", outfile)
        
        for index, key in sections.Keys() {
            for subindex, line in sections.Get(key) {
                FileOutLine(line, outfile)
            }
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
        
        MAIN_CALL_STRING := INDENT "Call(Trim(Monitor.GetHotkeyName(A_ThisHotkey), ""`;""))`r`n"
        MAIN_CALL_STRING .= INDENT "return"
        FileOutLine(MAIN_CALL_STRING, outfile)
    }
}

Main(INFILE, OUTFILE)
