@echo off
setlocal

:: Premessa: il metodo con GPO o Intune è più corretto, inoltre meglio non affidarsi solo alla chiave di registro per verificare l'aggiornamento dei cert

:: Check per verificare se il CERT è segnalato come già installato
for /f "tokens=3" %%A in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing" /v "UEFICA2023Status" 2^>nul') do set "STATUS=%%A"

if /i "%STATUS%"=="Updated" (
    echo UEFICA2023Status e' gia' impostato su Updated. Uscita in corso.
    exit /b 0
)

echo UEFICA2023Status non e' Updated. Procedo con le operazioni...

:: Aggiunta chiave di registro per segnalare l'update in WSUS
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Secureboot" /v AvailableUpdates /t REG_DWORD /d 0x5944 /f
if %errorlevel% neq 0 (
    echo Errore durante l'aggiunta della chiave di registro. Uscita in corso.
    exit /b 1
)

:: Avvio il task pianificato di MS
schtasks /run /tn "\Microsoft\Windows\PI\Secure-Boot-Update"
if %errorlevel% neq 0 (
    echo Errore durante l'avvio del task pianificato. Uscita in corso.
    exit /b 1
)

:: Valore da documentazione MS
echo In attesa che AvailableUpdates raggiunga il valore 0x4100 (decimale 16640)...

:ATTESA
timeout /t 10 /nobreak >nul

:: Se il valore non cambia in tempi accettabili aprire Windows Update e cercare gli aggiornamenti

set "VALORE_ATTUALE="
for /f "tokens=3" %%B in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Secureboot" /v "AvailableUpdates" 2^>nul') do set "VALORE_ATTUALE=%%B"

if /i "%VALORE_ATTUALE%"=="0x4100" goto COMPLETATO

echo Valore attuale: %VALORE_ATTUALE% - ancora in attesa...
goto ATTESA

:COMPLETATO
echo AvailableUpdates ha raggiunto il valore 0x4100. Riavvio del sistema in corso...
shutdown /r /t 5 /c "Aggiornamento Secure Boot completato - riavvio in corso"

endlocal
exit /b 0

:: Consigliabile rilanciare schtasks /run /tn "\Microsoft\Windows\PI\Secure-Boot-Update" dopo il riavvio se l'update non ha funzionato
