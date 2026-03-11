@echo off
setlocal

echo [1/4] Removing previous checks...
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\CompatMarkers" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Shared" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators" /f >nul 2>&1
echo Done.

echo [2/4] Spoofing hardware compatibility...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\HwReqChk" /v HwReqChkVars /t REG_MULTI_SZ /d "SQ_SecureBootCapable=TRUE\0SQ_SecureBootEnabled=TRUE\0SQ_TpmVersion=2\0SQ_RamMB=8192" /f >nul 2>&1
echo Done.

echo [3/4] Disabling TPM and CPU requirements..
reg add "HKLM\SYSTEM\Setup\MoSetup" /v AllowUpgradesWithUnsupportedTPMOrCPU /t REG_DWORD /d 1 /f >nul 2>&1
echo Done.

echo [4/4] Setting the eligibility marker...
reg add "HKCU\Software\Microsoft\PCHC" /v UpgradeEligibility /t REG_DWORD /d 1 /f >nul 2>&1
echo Done.

echo.
echo Checking if the registry keys were applied correctly...
set ERRORS=0

reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\HwReqChk" /v HwReqChkVars >nul 2>&1
if %errorlevel%==0 (echo [OK] HwReqChkVars) else (echo [FAIL] HwReqChkVars & set /a ERRORS+=1)

reg query "HKLM\SYSTEM\Setup\MoSetup" /v AllowUpgradesWithUnsupportedTPMOrCPU >nul 2>&1
if %errorlevel%==0 (echo [OK] AllowUpgradesWithUnsupportedTPMOrCPU) else (echo [FAIL] AllowUpgradesWithUnsupportedTPMOrCPU & set /a ERRORS+=1)

reg query "HKCU\Software\Microsoft\PCHC" /v UpgradeEligibility >nul 2>&1
if %errorlevel%==0 (echo [OK] UpgradeEligibility) else (echo [FAIL] UpgradeEligibility & set /a ERRORS+=1)

echo.
if %ERRORS%==0 (
    echo ############################################################
    echo                        DONE!                               #
    echo ############################################################
) else (
    echo ############################################################
    echo # Completed with %ERRORS% error(s). Check [FAIL] entries above. #
    echo ############################################################
	timeout 
)
echo.

endlocal
