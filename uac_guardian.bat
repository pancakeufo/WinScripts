@echo off
setlocal enabledelayedexpansion

title UAC GUARDIAN

:loop
for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin 2^>nul') do (
    set current=%%A
)
if not "!current!"=="0x3" (
    echo Valore modificato. Ripristino a 3.
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 3 /f >nul
)
timeout /t 30 /nobreak >nul
goto loop
