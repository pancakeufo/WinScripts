@echo off
setlocal enabledelayedexpansion

for %%L in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%L:\setup.exe" (
        cd /d %%L: 
        setup.exe /auto upgrade /dynamicupdate disable /eula accept /telemetry disable
        exit /b
    )
)

echo non hai montato la iso
endlocal
