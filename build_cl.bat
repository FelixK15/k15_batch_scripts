::version 1

set DEBUG_OUTPUT=0
set SCRIPT_DIRECTORY=%~dp0

set FORCE_DOWNLOAD_SCRIPTS=0
if "%1"=="update_scripts" (
    set FORCE_DOWNLOAD_SCRIPTS=1
)

if "!C_FILES!"=="" (
    echo Variable C_FILES not defined.
    set errorlevel=1
    goto ERROR_FAILURE
)

if "!OUTPUT_FILE_NAME!"=="" (
    echo Variable OUTPUT_FILE_NAME not defined.
    set errorlevel=1
    goto ERROR_FAILURE
)

if "!SOURCE_FOLDER!"=="" (
    set DEFAULT_SOURCE_FOLDER=%dp0%
    set SOURCE_FOLDER=!DEFAULT_SOURCE_FOLDER!

    if !DEBUG_OUTPUT! equ 1 (
        echo Variable SOURCE_FOLDER not defined, using default '!DEFAULT_SOURCE_FOLDER!'
    )
)

if "!BUILD_CONFIGURATION!"=="" (
    set DEFAULT_BUILD_CONFIGURATION=debug
    set BUILD_CONFIGURATION=!DEFAULT_BUILD_CONFIGURATION!

    if !DEBUG_OUTPUT! equ 1 (
        echo Variable BUILD_CONFIGURATION not defined, using default '!DEFAULT_BUILD_CONFIGURATION!'
    )
) else if not "!BUILD_CONFIGURATION!"=="debug" if not "!BUILD_CONFIGURATION!"=="release" (
    echo Wrong build config "!BUILD_CONFIGURATION!", assuming debug build
	set BUILD_CONFIG=debug
)

if "!OUTPUT_FOLDER!"=="" (
    set DEFAULT_OUTPUT_FOLDER=build
    set OUTPUT_FOLDER=!DEFAULT_OUTPUT_FOLDER!

    if !DEBUG_OUTPUT! equ 1 (
        echo Variable OUTPUT_FOLDER not defined, using default '!DEFAULT_OUTPUT_FOLDER!'
    )
)

if "!COMPILER_OPTIONS!"=="" (
    set DEFAULT_COMPILER_OPTIONS=/nologo /FC /TP /W3
    if "!BUILD_CONFIGURATION!"=="debug" (
        set DEFAULT_BUILD_CONFIGURATION=!DEFAULT_COMPILER_OPTIONS! /Od /Zi /GS /MTd
    ) else if "!BUILD_CONFIGURATION!"=="release" (
        set DEFAULT_BUILD_CONFIGURATION=!DEFAULT_COMPILER_OPTIONS! /O2 /GL /Gw /MT /DK15_RELEASE_BUILD
    )

    set COMPILER_OPTIONS=!DEFAULT_COMPILER_OPTIONS!

    if !DEBUG_OUTPUT! equ 1 (
        echo Variable COMPILER_OPTIONS not defined, using default '!DEFAULT_COMPILER_OPTIONS!'
    )
)

if "!LINKER_OPTIONS!"=="" (
    set DEFAULT_LINKER_OPTIONS=/SUBSYSTEM:WINDOWS
    set LINKER_OPTIONS=!DEFAULT_LINKER_OPTIONS!

    if !DEBUG_OUTPUT! equ 1 (
        echo Variable LINKER_OPTIONS not defined, using default '!DEFAULT_LINKER_OPTIONS!'
    )
)

set OUTPUT_FOLDER=!SCRIPT_DIRECTORY!!OUTPUT_FOLDER!\!BUILD_CONFIGURATION!

if not exist "!OUTPUT_FOLDER!" (
    echo !OUTPUT_FOLDER! doesn't exist, creating...
    mkdir !OUTPUT_FOLDER!
)

set CL_EXE_PATH_SCRIPT_PATH=!SCRIPT_DIRECTORY!find_cl_exe_path.bat
set VCVARS_PATH_SCRIPT_PATH=!SCRIPT_DIRECTORY!find_vcvars_path.bat
set CL_EXE_REPOSITORY_PATH=https://raw.githubusercontent.com/FelixK15/k15_batch_scripts/main/find_cl_exe_path.bat
set VCVARS_REPOSITORY_PATH=https://raw.githubusercontent.com/FelixK15/k15_batch_scripts/main/find_vcvars_path.bat

set DOWNLOAD_SCRIPTS=!FORCE_DOWNLOAD_SCRIPTS!
if not exist !CL_EXE_PATH_SCRIPT_PATH! (
    set DOWNLOAD_SCRIPTS=1
)

if !DOWNLOAD_SCRIPTS! EQU 1 (
    ::FK: Download file from github repository
    bitsadmin.exe /nowrap /transfer "'cl.exe find' script download job" !CL_EXE_REPOSITORY_PATH! !CL_EXE_PATH_SCRIPT_PATH! !VCVARS_REPOSITORY_PATH! !VCVARS_PATH_SCRIPT_PATH!

    if not ERRORLEVEL 0 (
        echo Error trying to download scripts from '!CL_EXE_REPOSITORY_PATH!' & '!VCVARS_REPOSITORY_PATH!'. Please check your internet connection.
        set errorlevel=2
        goto ERROR_FAILURE
    )
)

::FK: Populate COMPILER_PATH env var
call !CL_EXE_PATH_SCRIPT_PATH!

(for %%a in (!C_FILES!) do ( 
   set C_FILES_CONCATENATED="!SCRIPT_DIRECTORY!!SOURCE_FOLDER!%%a" !C_FILES_CONCATENATED!
))

set COMPILER_OPTIONS=!COMPILER_OPTIONS! /Fe"!OUTPUT_FOLDER!\!OUTPUT_FILE_NAME!"
set CL_COMMAND="!COMPILER_PATH!" !COMPILER_OPTIONS! !C_FILES_CONCATENATED! /link !LINKER_OPTIONS!
!CL_COMMAND!

:ERROR_FAILURE
echo build script exited with !errorlevel!