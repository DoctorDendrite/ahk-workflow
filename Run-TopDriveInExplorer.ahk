

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; --- Global Variables --- ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

__FILENAME__ := A_ScriptName
__PARAM_DELIM__ := "="
__VALUE_DELIM__ := ","

__DEFAULT_ARG__ := ""
__DEFAULT_AT__ := 1
__DEFAULT_TYPE__ := "FIXED" __VALUE_DELIM__ "REMOVABLE"

__HELP_MSG__ =
(
Usage: %__FILENAME__% [OPTION]...
Open explorer.exe to the topmost logical disk.
Best for use when navigating to external memory devices.

Options:

    --arg%__PARAM_DELIM__%[\]SUBFOLDER
            open explorer in "SUBFOLDER" on topmost logical disk

    --at%__PARAM_DELIM__%N
            open explorer to the NUMBER N-th topmost logical disk
            ( This is set to %__DEFAULT_AT__% by default. The topmost positions start at 1. )

    --ignore%__PARAM_DELIM__%STRING
            ignore each logical disk letter in STRING

    --type%__PARAM_DELIM__%WORD[%__VALUE_DELIM__%WORD]*
            select logical disk from list of disks of this type, or these types
            Valid set: ALL, CDROM, REMOVABLE, FIXED, NETWORK,
            RAMDISK, UNKNOWN
            ( This is set to "%__DEFAULT_TYPE__%" by default. )

    --help
            display this help message

Examples:

    Assume disk drives C, D, E, F

    %__FILENAME__%
        Attempts "F:\" in Windows Explorer

    %__FILENAME__% --arg%__PARAM_DELIM__%subfolder
        Attempts "F:\subfolder\" in Windows Explorer

    %__FILENAME__% --arg%__PARAM_DELIM__%subfolder --at%__PARAM_DELIM__%2
        Attempts "E:\subfolder\" in Windows Explorer

    %__FILENAME__% --arg%__PARAM_DELIM__%subfolder --at%__PARAM_DELIM__%2 --ignore%__PARAM_DELIM__%DE
        Attempts "C:\subfolder\" in Windows Explorer

Note:

    Windows Explorer will open to the system default directory if it fails
    to find the provided location, usually `%USERPROFILE`%\Documents.
)
 
 
;;;;;;;;;;;;;;;;;;;;;
; -- Parameters --- ;
;;;;;;;;;;;;;;;;;;;;;

; Defaults
;;;;;;;;;;

arg := __DEFAULT_ARG__
at := __DEFAULT_AT__
type := __DEFAULT_TYPE__

for index, param in A_Args {

    split := StrSplit(param, __PARAM_DELIM__)
    key := split[1]
    value := split[2]
    
	; Parameter names are case insensitive.
    StringLower, key, key
    
    ; Named parameters
    ;;;;;;;;;;;;;;;;;;
    
    if (key = "--help") {
    
        ; Get Help and Quit
        ;;;;;;;;;;;;;;;;;;;
        
        MsgBox % __HELP_MSG__
        return
        
    } else if (key = "--arg") {
        arg := value
    } else if (key = "--at") {
        at := 0 + value
    } else if (key = "--ignore") {
        ignore := value
    } else if (key = "--type") {
        type := value
    } else {
    
        ; Positional parameters
        ;;;;;;;;;;;;;;;;;;;;;;;
        
        if (index = 1) {
            arg := param
        } else if (index = 2) {
            at := param
        } else {
            ignore := param
        }
		
		; The 'type' argument does not have a positional parameter.
    }
}


;;;;;;;;;;;;;;;;;;;;;
; --- Functions --- ;
;;;;;;;;;;;;;;;;;;;;;

GetDiskNamesString(types_str) {
	global
	StringUpper, types_str, types_str
	
	if (types_str = "ALL") {
		DriveGet, disks, List, %word%
		return disks
	}
	
	str := ""
	
	for index, word in StrSplit(type, __VALUE_DELIM__) {
		DriveGet, disks, List, %word%
		str .= disks
	}
	
	return str
}

RemoveDiskNamesFromString(disks_str, removes_str) {
	Loop, Parse, removes_str
	{
		disks_str := StrReplace(disks_str, A_LoopField)
	}
	
	return disks_str
}

GetDiskName(disks_str, at) {
	return SubStr(disks_str, 1 - at, 1)
}

RunInExplorer(disk_name, arg) {
	global
	explorer_path := systemroot "\explorer.exe /n, /e, """ disk_name ":\" LTrim(arg, "\") """"
	Run, % explorer_path
}


;;;;;;;;;;;;;;;;;;;;;;
; --- Main Entry --- ;
;;;;;;;;;;;;;;;;;;;;;;

disks := GetDiskNamesString(type)
disks := RemoveDiskNamesFromString(disks, ignore)
disk := GetDiskName(disks, at)

RunInExplorer(disk, arg)
