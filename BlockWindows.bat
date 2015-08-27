@ECHO OFF
SETLOCAL

:: Check for administrative permissions
:: NOT TESTED ON WINDOWS 10.
net session >nul 2>&1
if not %errorLevel% == 0 (
	echo This script must be run as an administrator.
	pause
	exit /B
)

:: Harmful updates by type
set updates_validation=971033
set updates_getWindows10=2952664 2990214 3012973 3035583 3044374
set updates_performance=3021917
set updates_securityEssentials=2902907
set updates_telemetry=2976978 3022345 3068708 3075249 3080149
set updates_WindowsUpdate=3050265 3065987 3075853

:: If you believe a category is non-harmful, remove it from the following:
set updates=%updates_validation% %updates_securityEssentials%^
 %updates_getWindows10% %updates_performance% %updates_telemetry%^
 %updates_WindowsUpdate%

:: Uninstall Updates
echo Uninstalling harmful updates...
FOR %%U IN (%updates%) DO (
	echo 	Uninstalling KB%%U...
	wusa /kb:%%U /uninstall /quiet /norestart
)
echo - done

:: Hide Updates
echo Hiding harmful updates...
cscript /NoLogo "%~dp0HideWindowsUpdates.vbs" %updates%
echo - done

:: Block Routes
set routes=23.218.212.69 65.55.108.23 65.39.117.230 134.170.30.202^
 137.116.81.24 204.79.197.200
echo Blocking harmful routes...
FOR %%R IN (%routes%) DO (
	route -p add %%R MASK 255.255.255.255 0.0.0.0
)
echo - done

::Disable Tasks
echo Disabling harmful tasks...
set tasks="\Microsoft\Windows\Application Experience\AitAgent"^
 "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"^
 "\Microsoft\Windows\Application Experience\ProgramDataUpdater"^
 "\Microsoft\Windows\Autochk\Proxy"^
 "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"^
 "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"^
 "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"^
 "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"^
 "\Microsoft\Windows\Maintenance\WinSAT"^
 "\Microsoft\Windows\Media Center\ActivateWindowsSearch"^
 "\Microsoft\Windows\Media Center\ConfigureInternetTimeService"^
 "\Microsoft\Windows\Media Center\DispatchRecoveryTasks"^
 "\Microsoft\Windows\Media Center\ehDRMInit"^
 "\Microsoft\Windows\Media Center\InstallPlayReady"^
 "\Microsoft\Windows\Media Center\mcupdate"^
 "\Microsoft\Windows\Media Center\MediaCenterRecoveryTask"^
 "\Microsoft\Windows\Media Center\ObjectStoreRecoveryTask"^
 "\Microsoft\Windows\Media Center\OCURActivate"^
 "\Microsoft\Windows\Media Center\OCURDiscovery"^
 "\Microsoft\Windows\Media Center\PBDADiscovery"^
 "\Microsoft\Windows\Media Center\PBDADiscoveryW1"^
 "\Microsoft\Windows\Media Center\PBDADiscoveryW2"^
 "\Microsoft\Windows\Media Center\PvrRecoveryTask"^
 "\Microsoft\Windows\Media Center\PvrScheduleTask"^
 "\Microsoft\Windows\Media Center\RegisterSearch"^
 "\Microsoft\Windows\Media Center\ReindexSearchRoot"^
 "\Microsoft\Windows\Media Center\SqlLiteRecoveryTask"^
 "\Microsoft\Windows\Media Center\UpdateRecordPath"
FOR %%T in (%tasks%) DO (
	schtasks /Change /TN %%T /DISABLE
)
echo - done

echo Killing Diagtrack-service (if it still exists)...
sc stop Diagtrack
sc delete Diagtrack
echo - done

echo Stop remoteregistry-service (if it still exists)...
sc config remoteregistry start= disabled
sc stop remoteregistry

echo Done - Manually Reboot for changes to take effect
REM shutdown -r
pause
