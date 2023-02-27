::version 1

set SCRIPT_DIRECTORY=%~dp0
if "!C_FILES!"=="" (
    echo Variable C_FILES not defined.
    goto ERROR_FAILURE
)

if "!OUTPUT_FOLDER!"=="" (
    echo Variable OUTPUT_FOLDER not defined.
    goto ERROR_FAILURE
)

if "!OUTPUT_FILE_NAME!"=="" (
    echo Variable OUTPUT_FILE_NAME not defined.
    goto ERROR_FAILURE
)

if "!SOURCE_FOLDER!"=="" (
    echo Variable SOURCE_FOLDER not defined.
    goto ERROR_FAILURE
)

if "!COMPILER_OPTIONS!"=="" (
    echo Variable COMPILER_OPTIONS not defined.
    goto ERROR_FAILURE
)

set CLANG_EXE_PATH_SCRIPT_PATH=!SCRIPT_DIRECTORY!find_clang_exe_path.bat
set CLANG_EXE_REPOSITORY_PATH=https://raw.githubusercontent.com/FelixK15/k15_batch_scripts/main/find_clang_exe_path.bat

if not exist !CL_EXE_PATH_SCRIPT_PATH! (
    ::FK: Download file from github repository
    bitsadmin.exe /transfer "'clang.exe find' script download job" !CLANG_EXE_REPOSITORY_PATH! !CLANG_EXE_PATH_SCRIPT_PATH!

    if not ERRORLEVEL 0 (
        echo Error trying to download script from '!CLANG_EXE_REPOSITORY_PATH!'. Please check your internet connection.
        goto ERROR_FAILURE
    )
)

FOR /F "tokens=*" %%g IN ('call !CLANG_EXE_PATH_SCRIPT_PATH!') do (SET CLANG_EXE_PATH=%%g)

(for %%a in (!C_FILES!) do ( 
   set C_FILES_CONCATENATED="!SCRIPT_DIRECTORY!!SOURCE_FOLDER!%%a" !C_FILES_CONCATENATED!
))

set CLANG_COMMAND="!CLANG_EXE_PATH!" !COMPILER_OPTIONS! !C_FILES_CONCATENATED!
!CLANG_COMMAND!
exit /b

:ERROR_FAILURE
echo build script exited with error
exit /b 1