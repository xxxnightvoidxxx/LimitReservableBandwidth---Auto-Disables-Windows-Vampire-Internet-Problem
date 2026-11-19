@echo off
setlocal
color 0B
title Disable Windows Reserved Bandwidth - Fixed /reg:64
mode con: cols=78 lines=32

:: ============================================================
::  DISABLE WINDOWS QoS RESERVED BANDWIDTH (NonBestEffortLimit)
::  --------------------------------------------------------
::  FIXED VERSION: forces /reg:64 so the value lands in the
::  standard 64-bit view you see in regedit.
::
::  Registry target:
::    HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched
::        NonBestEffortLimit  (REG_DWORD) = 0
:: ============================================================

echo.
echo  ============================================================
echo    DISABLE WINDOWS QoS RESERVED BANDWIDTH
echo    FIXED: forced 64-bit registry view (/reg:64)
echo  ============================================================
echo.
echo  Writing to:
echo    HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched
echo    NonBestEffortLimit = 0  (REG_DWORD)
echo.
echo  ------------------------------------------------------------
echo.

:: ---- Admin check ----
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo  [X] ACCESS DENIED - Run this file as Administrator.
    echo.
    echo      Right-click the .bat file ^> "Run as administrator"
    echo.
    pause
    exit /b 1
)
echo  [OK] Admin confirmed.
echo.

:: ---- Ensure the key exists (creates if missing) ----
echo  [*] Ensuring key exists...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /f /reg:64 >nul 2>&1
echo  [OK] Key ready.
echo.

:: ---- Write the value with /reg:64 ----
echo  [*] Writing NonBestEffortLimit = 0 ...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v NonBestEffortLimit /t REG_DWORD /d 0 /f /reg:64 >nul 2>&1

if %errorlevel% neq 0 (
    color 0C
    echo  [X] Registry write FAILED. Check permissions.
    pause
    exit /b 1
)
echo  [OK] Write command returned success.
echo.

:: ---- Verify by querying the 64-bit view explicitly ----
echo  [*] Verifying via /reg:64 query...
set "VAL="
for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v NonBestEffortLimit /reg:64 2^>nul ^| find "NonBestEffortLimit"') do set "VAL=%%A"

if "%VAL%"=="0x0" (
    color 0A
    echo  [OK] VERIFIED: NonBestEffortLimit = 0x0  (0%% reserved)
    echo.
    echo  You can now open regedit and navigate to:
    echo    HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched
    echo  You WILL see NonBestEffortLimit there.
) else (
    color 0E
    echo  [!] Verification returned: %VAL%
    echo      Expected 0x0. If empty, check regedit manually.
)

echo.
echo  ============================================================
echo    DONE. Restart your PC for the policy to take effect.
echo    To undo: change /d 0 to /d 20 and re-run.
echo  ============================================================
echo.
pause
endlocal