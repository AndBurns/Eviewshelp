@echo off
setlocal enabledelayedexpansion

:: Set the source directory and target directory
set "source_dir=W:\MFM\MACROXSUPPORT\BGD"
set "target_dir=C:\GIT\EVIEWSHELP\PRG"
set "file_extension=*.PRG"   :: You can change this to the desired file extension (e.g., *.jpg, *.docx)

:: Ensure the target directory exists
if not exist "%target_dir%" (
    mkdir "%target_dir%"
)

:: Traverse the source directory and its subdirectories
for /r "%source_dir%" %%f in (%file_extension%) do (
    :: Get the relative path from the source directory
    set "file=%%f"
    set "relative_path=!file:%source_dir%=!"
    set "relative_path=!relative_path:\=_!"

    :: Extract the file name
    set "filename=%%~nxf"

    :: Create the new file name based on path and filename
    set "new_filename=!relative_path!_!filename!"

    :: Copy the file to the target directory with the new name
    copy "%%f" "%target_dir%\!new_filename!"
)

echo Files have been copied and renamed successfully.
endlocal