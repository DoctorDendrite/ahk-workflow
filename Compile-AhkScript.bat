
:: REQUIRES
:: --------
:: Ahk2Exe.exe - See `compiler` in PARAMETERS.

:: ERROR CODES
:: -----------
:: 1 - Failed to compile script
:: 2 - Failed to create shortcut in Startup folder
:: 3 - Failed due to lack of administrative clearance

@ECHO OFF
SETLOCAL EnableDelayedExpansion


:: *********************
:: * --- CONSTANTS --- *
:: *********************

SET "DEFAULT_COMPILER_PATH=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"


:: *********************
:: * --- HELP EXIT --- *
:: *********************

IF "%1" EQU "/?" GOTO HelpMessage
IF "%1" EQU ""   GOTO HelpMessage


:: **********************
:: * --- PARAMETERS --- *
:: **********************

SET "what="
SET "force=false"
SET "shortcut=true"
SET "whatif=false"
SET "compiler=%DEFAULT_COMPILER_PATH%"

FOR %%a IN (%*) DO (
    IF "%%a" EQU "/f" (
		SET "force=true"
	) ELSE IF "%%a" EQU "/F" (
		SET "force=true"
	) ELSE IF "%%a" EQU "/n" (
		SET "shortcut=false"
	) ELSE IF "%%a" EQU "/N" (
		SET "shortcut=false"
	) ELSE IF "%%a" EQU "/w" (
		SET "whatif=true"
	) ELSE IF "%%a" EQU "/W" (
		SET "whatif=true"
	) ELSE (
		SET "comp=%%a"
		IF "!comp:~0,10!" EQU "/COMPILER_" (
			SET "compiler=!comp:/COMPILER_=!"
		) ELSE IF "!comp:~0,10!" EQU "/compiler_" (
			SET "compiler=!comp:/compiler_=!"
		) ELSE (
			SET "what=%%~a"
		)
	)
)


:: :: ****************
:: :: * --- TEST --- *
:: :: ****************
:: 
:: echo Force:    [%force%]
:: echo Shortcut: [%shortcut%]
:: echo WhatIf:   [%whatif%]
:: echo What:     [%what%]
:: echo Compiler: [%compiler%]
:: 
:: EXIT /B %errorlevel%


:: **********************
:: * --- MAIN ENTRY --- *
:: **********************

CALL :Main "%what%" "%force%" "%shortcut%" "%whatif%" "%compiler%"
EXIT /B %errorlevel%

:Main
SET "name=%~n1"
SET "force=%~2"
SET "shortcut=%~3"
SET "whatif=%~4"
SET "compiler=%~5"

SET "startMenuPath=%UserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
SET "scriptName=%~n1.ahk"
SET "newAppShortName=%~n1.exe"
SET "newAppName=%~dp0%~n1.exe"
SET "newLinkShortName=%~n1.exe - Shortcut.lnk"
SET "newLinkName=%startMenuPath%\%newLinkShortName%"
SET "errorLevel=0"

CALL :CheckAndRemoveIfOriginalExists "%newAppName%" "%newAppShortName%" "%force%" "%whatif%" errorlevel

IF "!errorlevel!" NEQ "0" GOTO EndOfScript

ECHO Compiling script...

IF "%whatif%" EQU "false" (
	"%compiler%" /in "%scriptName%"
)

IF "!errorLevel!" NEQ "0" GOTO EndOfScript

IF EXIST "%newAppName%" (

    ECHO New application: "%newAppShortName%" created.
    
    IF "!errorLevel!" EQU "0" (
    
		IF "%shortcut%" EQU "true" (
			CALL :CheckAndRemoveIfOriginalExists "%newLinkName%" "%newLinkShortName%" "%force%" "%whatif%" errorlevel
			CALL :CreateShortcut "%newLinkName%" "%newAppName%" "%whatif%" errorLevel
		)
        
        IF "!errorLevel!" NEQ "0" (
            ECHO WARNING: Creating link: "%newLinkShortName%" failed.
        )
        
        IF "!errorLevel!" EQU "0" (
            ENDLOCAL
            SET "errorLevel=0"
            EXIT /B
        )
        
        IF "!errorLevel!" EQU "1" (
            ENDLOCAL
            SET "errorLevel=1"
            EXIT /B
        )
        
        IF "!errorLevel!" EQU "2" (
            ENDLOCAL
            SET "errorLevel=2"
            EXIT /B
        )
        
        IF "!errorLevel!" EQU "3" (
            ENDLOCAL
            SET "errorLevel=3"
            EXIT /B
        )
    )
)


:: ***********************
:: * --- SUBROUTINES --- *
:: ***********************

:DeleteOriginalFile
SET "linkName=%~1"
SET "shortcutName=%~2"
SET "whatif=%~3"
SET "errorFlagName=%4"

ECHO Deleting...

IF "%whatif%" EQU "false" (
	SET line=0
	FOR /F "tokens=* delims=" %%i IN ('2^>^&1 del "%linkName%"') DO (
	
		>NUL SET /a line+=1
		SET resultMessage=%%i
		ECHO !resultMessage!
		
		FOR /F "tokens=1 delims= " %%j IN ('ECHO !resultMessage!') DO (
		
			IF "!line!" EQU "2" (
			
				SET startingWord=%%j
				
				IF "!startingWord!" EQU "Access" (
					SET %errorFlagName%=3
				) ELSE (
					SET %errorFlagName%=0
				)
			)
		)
	)
)

IF "%whatif%" EQU "true" (
	SET line=0
)

IF "!line!" EQU "0" (
    ECHO File "%shortcutName%" deleted.
    SET %errorFlagName%=0
)

EXIT /B

:CreateShortcut
SET "linkName=%~1"
SET "appName=%~2"
SET "whatif=%~3"
SET "errorFlagName=%4"

ECHO Creating shortcut...

IF "%whatif%" EQU "false" (
	SET particle="Cannot
	
	FOR /F "tokens=* delims=" %%i IN ('2^>^&1 mklink "%linkName%" "%appName%"') DO (
	
		SET resultMessage=%%i
		ECHO !resultMessage!
		
		FOR /F "tokens=1 delims= " %%j IN ('ECHO "!resultMessage!"') DO (
		
			SET startingWord=%%j
			
			IF "!startingWord!" EQU "!particle!" (
				IF "!errorLevel!" EQU "0" (
					SET %errorFlagName%=2
				)
			)
		)
	)
)

EXIT /B

:CheckAndRemoveIfOriginalExists
SET "linkName=%~1"
SET "shortcutName=%~2"
SET "force=%~3"
SET "whatif=%~4"
SET "errorFlagName=%5"

IF EXIST "%linkName%" (

    SET %errorFlagName%=1
    ECHO A copy of the original "%shortcutName%" still exists.
    
    IF "%force%" EQU "true" CALL :DeleteOriginalFile "%linkName%" "%shortcutName%" "%whatif%" %errorFlagName%
)

EXIT /B

:HelpMessage
ECHO.
ECHO %~nx0 [/F] [/N] [[drive:]path]^<filename^> [/COMPILER_^<compiler^>]
ECHO.
ECHO Description:
ECHO.    Compiles an AutoHotkey script to a binary file (*.exe) using Ahk2Exe.exe.
ECHO.    A copy of the *.exe is kept in the current script location, and a symbolic
ECHO.    link is placed in the Startup folder:
ECHO.
ECHO.      %UserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
ECHO.
ECHO Parameter List:
ECHO.    /F        Replace duplicate files by force
ECHO.
ECHO.    /N        Do not place a symbolic link in the Startup folder
ECHO.
ECHO.    drive     A drive letter
ECHO.
ECHO.    path      The path to an AutoHotkey file (*.ahk)
ECHO.
ECHO.    filename  The name of the AutoHotkey file (*.ahk) to compile
ECHO.
ECHO.    compiler  The full name of the compiler ("Ahk2Exe.exe")
ECHO.              Default:
ECHO.
ECHO.      %DEFAULT_COMPILER_PATH%
ECHO.
ECHO.    /?        Display this help message
ECHO.
ECHO.  NOTE: The script returns an error level of 0 if the process is successful,
ECHO.        of 1 if the compile is unsuccessful, of 2 if the symbolic link is
ECHO.        unsuccessful, and of 3 for failures and errors.
ECHO.
ECHO Examples:
ECHO.    %~nx0 /?
ECHO.    %~nx0 scriptname.ahk
ECHO.    %~nx0 \scriptname.ahk
ECHO.    %~nx0 C:\scripts\scriptname.ahk
ECHO.    %~nx0 C:\scripts\scriptname.ahk /COMPILER_C:\scripts\Ahk2Exe.exe
ECHO.    %~nx0 "C:\Program Files\AutoHotkey\Scripts\scriptname.ahk"
ECHO.    %~nx0 /F scriptname.ahk
EXIT /B !errorlevel!

:EndOfScript
ECHO WARNING: Compiling script: "%scriptName%" failed.
EXIT /B !errorLevel!
