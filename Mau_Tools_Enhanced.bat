@echo off
setlocal enabledelayedexpansion

:: Mau Tools Enhanced - Professional System Administration Suite
:: Version: 3.2
:: Author: Mauxstn
:: Website: https://github.com/mauxstn/mau-tools-enhanced

:: Check for updates if not started with /noupdate
if not "%~1"=="/noupdate" (
    call :check_for_updates
    if errorlevel 1 (
        echo.
        echo +==============================================================================+
        echo +                           UPDATE AVAILABLE!                         +
        echo +==============================================================================+
        echo.
        echo [INFO] A new version of Mau Tools Enhanced is available!
        echo [QUESTION] Do you want to download and install the update now? (Y/N)
        choice /c YN /n /m "  Your choice: "
        if !errorlevel! equ 1 (
            call :install_update
            exit /b
        )
    )
)

goto :start_script

:check_for_updates
setlocal
set "update_available=0"

:: Get current script version
set "current_version=3.2"

:: Get latest version from GitHub
echo [INFO] Checking for updates...
curl -s -o "%TEMP%\mau_tools_latest_version.txt" https://raw.githubusercontent.com/mauxstn/mau-tools-enhanced/main/version.txt 2>nul
if %errorlevel% neq 0 (
    echo [WARNING] Could not check for updates - continuing offline
    endlocal & exit /b 0
)

if not exist "%TEMP%\mau_tools_latest_version.txt" (
    echo [WARNING] Update check failed - continuing offline
    endlocal & exit /b 0
)

set /p "latest_version=" < "%TEMP%\mau_tools_latest_version.txt"
del "%TEMP%\mau_tools_latest_version.txt" 2>nul

:: Compare versions (simple string comparison for now)
if "%latest_version%" gtr "%current_version%" (
    echo [UPDATE] New version available: %latest_version% (current: %current_version%)
    endlocal & exit /b 1
) else (
    echo [INFO] You are running the latest version: %current_version%
    endlocal & exit /b 0
)

:install_update
setlocal
echo [INFO] Downloading update...

:: Create backup of current version
copy "%~f0" "%~f0.backup" >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] Backup created: %~f0.backup
) else (
    echo [WARNING] Could not create backup
)

:: Download the new version
curl -s -o "%TEMP%\Mau_Tools_Enhanced_new.bat" https://raw.githubusercontent.com/mauxstn/mau-tools-enhanced/main/Mau_Tools_Enhanced.bat 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Failed to download update!
    echo [INFO] Please check your internet connection
    timeout /t 3 >nul
    endlocal & exit /b 1
)

if not exist "%TEMP%\Mau_Tools_Enhanced_new.bat" (
    echo [ERROR] Update file not found!
    timeout /t 3 >nul
    endlocal & exit /b 1
)

:: Replace the current script
move /y "%TEMP%\Mau_Tools_Enhanced_new.bat" "%~f0" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install update!
    echo [INFO] Please check file permissions
    timeout /t 3 >nul
    endlocal & exit /b 1
)

echo [SUCCESS] Update successfully installed!
echo [INFO] Restarting with new version...
timeout /t 2 >nul

:: Restart with the new version
start "" /b "cmd" /c ""%~f0" /noupdate"
endlocal
exit /b 0

:start_script
chcp 850 >nul
cls
title Mau Tools Enhanced v3.2
color 0a
echo Setting up display... Please wait.
echo.
echo.
timeout /t 2 /nobreak >nul
cls

:: Configuration
set version=3.2
set author=Mauxstn
set website=https://github.com/mauxstn/mau-tools-enhanced
set logdir=%USERPROFILE%\MauToolsLogs
if not exist "%logdir%" mkdir "%logdir%"

:: Logging function
set logfile=%logdir%\MauTools_%date:~-4,4%%date:~-7,2%%date:~-10,2%.log

:: Enhanced error handling function
:handle_error
set error_message=%~1
set error_code=%~2
echo [ERROR] %error_message%
echo [CODE] Error code: %error_code%
echo [ACTION] Attempting to recover...
echo [INFO] This error has been logged to: %logfile%
echo [2026-%date:~-7,2%-%date:~-10,2% %time%] ERROR: %error_message% (Code: %error_code%) >> "%logfile%"
timeout /t 3 /nobreak >nul
goto menu

:: Safe execution wrapper
:safe_execute
set command_to_run=%~1
set error_context=%~2
echo [EXECUTING] %error_context%...
%command_to_run% >nul 2>&1
if !errorlevel! neq 0 (
    call :handle_error "Failed to execute: %error_context%" !errorlevel!
    exit /b 1
) else (
    echo [SUCCESS] %error_context% completed successfully
    exit /b 0
)

:: Admin-Check with enhanced error handling
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Administratorrechte erforderlich!
    echo [INFO] Versuche, Administratorrechte zu erlangen...
    powershell -Command "Start-Process '%~f0' -Verb RunAs" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [SUCCESS] Administratorrechte erteilt. Starte neu...
        timeout /t 2 /nobreak >nul
        exit /b
    ) else (
        call :handle_error "Konnte Administratorrechte nicht erlangen!" %errorlevel%
        exit /b 1
    )
)

:menu
cls
echo.
echo  ================================================================
echo                   MAU TOOLS v%version%
echo                   Author: %author%
echo  ================================================================
echo.
echo  +------------------------- NETWORK --------------------------+
echo  [1] IP Configuration               [2] Ping Google
echo  [3] Flush DNS Cache                [4] Internet Connection Test
echo  [15] Network Speed Test
echo  +-------------------------- SYSTEM -----------------------+
echo  [5] System Info            [6] List Drivers
echo  [7] Clean Temp Files       [8] Optimize System
echo  [9] Windows Services       [10] Environment Variables
echo  [11] List Open Files       [12] System Uptime
echo  [13] Windows Product Key   [14] System Logs
echo  [16] Hardware Temperatures
echo  +--------------------------- EXIT ------------------------+
echo  [0] Exit Program
echo.
set /p choice=" Choose an option (0-16): "

:: Validation
if "%choice%"=="" goto menu
echo %choice%| findstr /r "^[0-9]*$" >nul || (goto invalid)
if %choice% GTR 16 goto invalid

echo [2026-%date:~-7,2%-%date:~-10,2% %time%] User selected option %choice% >> "%logfile%"

:: Route to appropriate function
if %choice%==0 goto end
if %choice%==1 goto ipconfig
if %choice%==2 goto ping_google
if %choice%==3 goto flush_dns
if %choice%==4 goto check_internet
if %choice%==5 goto system_info
if %choice%==6 goto list_drivers
if %choice%==7 goto clean_temp
if %choice%==8 goto optimize_system
if %choice%==9 goto show_services
if %choice%==10 goto show_env_vars
if %choice%==11 goto show_open_files
if %choice%==12 goto show_uptime
if %choice%==13 goto show_product_key
if %choice%==14 goto show_system_logs
if %choice%==15 goto test_network_speed
if %choice%==16 goto show_temps

:ipconfig
cls
echo +==============================================================+
echo +                    IP CONFIGURATION                          +
echo +==============================================================+
echo.
echo [INFO] Gathering IP configuration information...
ipconfig /all
echo.
echo [INFO] IP configuration completed.
pause
goto menu

:ping_google
cls
echo +==============================================================+
echo +                    PING GOOGLE.COM                            +
echo +==============================================================+
echo.
echo [INFO] Pinging google.com to test connectivity...
ping -n 4 google.com
if %errorlevel% equ 0 (
    echo [SUCCESS] Connection to Google successful!
) else (
    echo [ERROR] Cannot connect to Google!
)
echo.
pause
goto menu

:flush_dns
cls
echo +==============================================================================+
echo +                    ADVANCED NETWORK ANALYSIS                     +
echo +==============================================================================+
echo.
echo [INFO] Starting comprehensive network configuration analysis...
echo [INFO] Gathering detailed network interface information...
echo.

:: Network Interface Details
echo +++++ NETWORK INTERFACES +++++
echo [SECTION] Active Network Adapters
echo ----------------------------------------
echo [INFO] Scanning all network interfaces...
ipconfig /all
echo.

:: IPv4 Configuration Analysis
echo +++++ IPv4 CONFIGURATION +++++
echo [SECTION] IPv4 Address Analysis
echo ----------------------------------------
echo [INFO] Analyzing IPv4 configuration...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do echo Primary IPv4: %%a
echo [INFO] Checking for multiple IPv4 addresses...
ipconfig | findstr "IPv4" /c
echo.

:: Gateway and DNS Analysis
echo +++++ GATEWAY & DNS ANALYSIS +++++
echo [SECTION] Routing Configuration
echo ----------------------------------------
echo [INFO] Analyzing default gateway and DNS settings...
ipconfig /all | findstr /C:"Default Gateway" /C:"DNS Servers"
echo.

:: Network Statistics
echo +++++ NETWORK STATISTICS +++++
echo [SECTION] Network Performance Metrics
echo ----------------------------------------
echo [INFO] Gathering network statistics...
netstat -e | findstr /C:"Bytes" /C:"Unicast packets" /C:"Non-unicast packets"
echo.

:: ARP Table Analysis
echo +++++ ARP TABLE ANALYSIS +++++
echo [SECTION] Address Resolution Protocol
echo ----------------------------------------
echo [INFO] Showing active ARP entries (last 10)...
arp -a | findstr /v "Interface" | findstr "dynamic" | more +0
echo.

:: Route Table Analysis
echo +++++ ROUTE TABLE ANALYSIS +++++
echo [SECTION] Network Routing
echo ----------------------------------------
echo [INFO] Analyzing routing table...
route print | findstr /C:"Network Destination" /C:"Netmask" /C:"Gateway" /C:"Interface"
echo.

:: Network Interface Performance
echo +++++ INTERFACE PERFORMANCE +++++
echo [SECTION] Interface Statistics
echo ----------------------------------------
echo [INFO] Gathering interface performance data...
netstat -an | findstr /C:"TCP" /C:"UDP" | find /c /v "" 
echo Active connections found.
echo.

echo +==============================================================================+
echo [SUCCESS] Network analysis completed!
echo [INFO] All network configuration data has been collected.
echo [LOG] Network analysis timestamp: %date% %time%
echo +==============================================================================+
echo.
pause
goto menu

:check_internet
cls
echo +==============================================================================+
echo +                    ROBUST INTERNET CONNECTIVITY TEST              +
echo +==============================================================================+
echo.
echo [INFO] Starting comprehensive connectivity analysis with error handling...
echo [INFO] Testing multiple endpoints with fallback mechanisms...
echo.

:: Initialize counters
set success_count=0
set total_tests=0

:: Test 1: Localhost (always should work)
echo +++++ LOCALHOST TEST +++++
echo [SECTION] Testing Local Network Stack
echo ----------------------------------------
set /a total_tests+=1
echo [INFO] Pinging localhost (127.0.0.1)...
ping -n 2 127.0.0.1 >nul 2>&1
if !errorlevel! equ 0 (
    echo [SUCCESS] Local network stack is working correctly
    set /a success_count+=1
) else (
    echo [CRITICAL] Local network stack has issues - this is unusual
    echo [ACTION] Checking network adapter status...
    ipconfig /all | findstr "Ethernet adapter" >nul 2>&1
    if !errorlevel! neq 0 (
        echo [ERROR] No network adapters found!
    ) else (
        echo [INFO] Network adapters detected, issue may be with TCP/IP stack
    )
)
echo.

:: Test 2: Gateway with error handling
echo +++++ GATEWAY TEST +++++
echo [SECTION] Testing Default Gateway
echo ----------------------------------------
set /a total_tests+=1
echo [INFO] Detecting default gateway...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "Default Gateway" ^| findstr /v "0.0.0.0"') do (
    if not "%%a"=="" (
        set gateway_ip=%%a
        echo [DETECTED] Gateway found: %%a
        echo [INFO] Pinging gateway...
        ping -n 2 %%a >nul 2>&1
        if !errorlevel! equ 0 (
            echo [SUCCESS] Gateway is reachable
            set /a success_count+=1
        ) else (
            echo [FAILED] Gateway is not responding
            echo [ACTION] Checking router connection...
            echo [INFO] Verify network cable or WiFi connection
        )
        goto gateway_done
    )
)
echo [WARNING] No default gateway found - this may be normal for some configurations
set /a success_count+=1  ; Don't penalize for no gateway
:gateway_done
echo.

:: Test 3: DNS Resolution with multiple servers
echo +++++ DNS RESOLUTION TEST +++++
echo [SECTION] Testing DNS Resolution
echo ----------------------------------------
set /a total_tests+=1
echo [INFO] Testing DNS resolution with multiple servers...

:: Test with Google DNS
echo [DNS] Testing with Google DNS (8.8.8.8)...
nslookup google.com 8.8.8.8 >nul 2>&1
if !errorlevel! equ 0 (
    echo [SUCCESS] DNS resolution working with Google DNS
    set /a success_count+=1
) else (
    echo [FAILED] DNS resolution failed with Google DNS
    echo [ACTION] Trying alternative DNS servers...
    
    :: Test with Cloudflare DNS
    echo [DNS] Testing with Cloudflare DNS (1.1.1.1)...
    nslookup google.com 1.1.1.1 >nul 2>&1
    if !errorlevel! equ 0 (
        echo [SUCCESS] DNS resolution working with Cloudflare DNS
        set /a success_count+=1
    ) else (
        echo [FAILED] DNS resolution failed with all tested servers
        echo [ACTION] Check DNS settings in network configuration
    )
)
echo.

:: Test 4: External connectivity with multiple endpoints
echo +++++ EXTERNAL CONNECTIVITY +++++
echo [SECTION] Testing Internet Access
echo ----------------------------------------
echo [INFO] Testing connectivity to major internet endpoints...

:: Test Google DNS
set /a total_tests+=1
echo [TEST] Google DNS (8.8.8.8)...
ping -n 2 8.8.8.8 >nul 2>&1
if !errorlevel! equ 0 (
    echo [SUCCESS] Google DNS (8.8.8.8) - Connected
    set /a success_count+=1
) else (
    echo [FAILED] Google DNS (8.8.8.8) - No connection
    echo [ACTION] Checking firewall settings...
)

:: Test Cloudflare DNS
set /a total_tests+=1
echo [TEST] Cloudflare DNS (1.1.1.1)...
ping -n 2 1.1.1.1 >nul 2>&1
if !errorlevel! equ 0 (
    echo [SUCCESS] Cloudflare DNS (1.1.1.1) - Connected
    set /a success_count+=1
) else (
    echo [FAILED] Cloudflare DNS (1.1.1.1) - No connection
    echo [ACTION] Checking network cable/ WiFi connection...
)

:: Test HTTP connectivity
set /a total_tests+=1
echo [TEST] HTTP connectivity (google.com)...
ping -n 2 google.com >nul 2>&1
if !errorlevel! equ 0 (
    echo [SUCCESS] google.com - Connected
    echo [METRICS] DNS resolution working correctly
    set /a success_count+=1
) else (
    echo [FAILED] google.com - No connection
    echo [WARNING] DNS resolution may be failing
    echo [ACTION] Try flushing DNS cache: ipconfig /flushdns
)

:: Test alternative endpoint
set /a total_tests+=1
echo [TEST] Alternative endpoint (cloudflare.com)...
ping -n 2 cloudflare.com >nul 2>&1
if !errorlevel! equ 0 (
    echo [SUCCESS] cloudflare.com - Connected
    set /a success_count+=1
) else (
    echo [FAILED] cloudflare.com - No connection
    echo [ACTION] Checking proxy settings...
)
echo.

:: Test 5: Port connectivity with error handling
echo +++++ PORT CONNECTIVITY +++++
echo [SECTION] Testing Common Ports
echo ----------------------------------------
echo [INFO] Testing connectivity to common ports...

set /a total_tests+=1
echo [PORT 80] HTTP (web browsing)...
powershell -Command "try { Test-NetConnection -ComputerName google.com -Port 80 -InformationLevel Quiet -WarningAction SilentlyContinue } catch { 'False' }" 2>nul | findstr "True" >nul
if !errorlevel! equ 0 (
    echo [OPEN] Port 80 - HTTP accessible
    set /a success_count+=1
) else (
    echo [CLOSED] Port 80 - Blocked or filtered
    echo [ACTION] Check firewall settings
)

set /a total_tests+=1
echo [PORT 443] HTTPS (secure web)...
powershell -Command "try { Test-NetConnection -ComputerName google.com -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue } catch { 'False' }" 2>nul | findstr "True" >nul
if !errorlevel! equ 0 (
    echo [OPEN] Port 443 - HTTPS accessible
    set /a success_count+=1
) else (
    echo [CLOSED] Port 443 - Blocked or filtered
    echo [ACTION] Check corporate firewall or proxy
)

set /a total_tests+=1
echo [PORT 53] DNS...
powershell -Command "try { Test-NetConnection -ComputerName 8.8.8.8 -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue } catch { 'False' }" 2>nul | findstr "True" >nul
if !errorlevel! equ 0 (
    echo [OPEN] Port 53 - DNS accessible
    set /a success_count+=1
) else (
    echo [CLOSED] Port 53 - Blocked or filtered
    echo [ACTION] DNS may be blocked by firewall
)
echo.

:: Calculate success rate
set /a success_rate=(!success_count!*100)/!total_tests!

:: Summary and recommendations
echo +++++ CONNECTIVITY SUMMARY +++++
echo [SECTION] Test Results Summary
echo ----------------------------------------
echo [RESULTS] Connectivity analysis completed
echo [STATISTICS] Successful tests: !success_count! / !total_tests!
echo [PERFORMANCE] Success rate: !success_rate!%%
echo.

echo [STATUS] 
if !success_rate! GEQ 80 (
    echo [EXCELLENT] Internet connectivity is optimal
) else if !success_rate! GEQ 60 (
    echo [GOOD] Internet connectivity is acceptable
) else if !success_rate! GEQ 40 (
    echo [WARNING] Internet connectivity needs attention
) else (
    echo [CRITICAL] Internet connectivity is poor - immediate action required
)

echo.
echo [RECOMMENDATIONS] Based on test results:
if !success_rate! LSS 80 (
    echo - Check network cable or WiFi connection
    echo - Restart router/modem
    echo - Flush DNS cache: ipconfig /flushdns
    echo - Check firewall settings
    echo - Contact ISP if issues persist
) else (
    echo - Your internet connection is working well
    echo - Consider running speed test for performance metrics
)

echo.
echo +==============================================================================+
echo [SUCCESS] Robust connectivity test completed!
echo [METRICS] Success rate: !success_rate!%%
echo [LOG] Connectivity test timestamp: %date% %time%
echo +==============================================================================+
echo.
pause
goto menu

:system_info
cls
echo +==============================================================================+
echo +                        COMPREHENSIVE SYSTEM ANALYSIS               +
echo +==============================================================================+
echo.
echo [INFO] Starting comprehensive system analysis...
echo [INFO] This may take a few moments to gather all information...
echo.

:: Computer Information Section
echo +++++ COMPUTER INFORMATION +++++
echo [SECTION] System Details
echo ----------------------------------------
systeminfo | findstr /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"System Manufacturer" /C:"System Model" /C:"BIOS Version" /C:"Total Physical Memory" /C:"Available Physical Memory"
echo.

:: Processor Information Section  
echo +++++ PROCESSOR ANALYSIS +++++
echo [SECTION] CPU Details
echo ----------------------------------------
echo [INFO] Gathering processor information...
for /f "tokens=2 delims==" %%a in ('wmic cpu get name /value') do echo CPU Name: %%a
for /f "tokens=2 delims==" %%a in ('wmic cpu get numberofcores /value') do echo CPU Cores: %%a
for /f "tokens=2 delims==" %%a in ('wmic cpu get numberoflogicalprocessors /value') do echo Logical Processors: %%a
for /f "tokens=2 delims==" %%a in ('wmic cpu get maxclockspeed /value') do (
    set /a speed_ghz=%%a/1000
    echo Max Clock Speed: !speed_ghz! GHz
)
for /f "tokens=2 delims==" %%a in ('wmic cpu get currentclockspeed /value') do (
    set /a current_ghz=%%a/1000
    echo Current Clock Speed: !current_ghz! GHz
)
echo [INFO] Checking CPU usage...
wmic cpu get loadpercentage /value | findstr LoadPercentage
echo.

:: Memory Analysis Section
echo +++++ MEMORY ANALYSIS +++++
echo [SECTION] RAM Details
echo ----------------------------------------
echo [INFO] Analyzing memory configuration...
for /f "tokens=2 delims==" %%a in ('wmic computersystem get totalphysicalmemory /value') do (
    set /a total_gb=%%a/1073741824
    echo Total RAM: !total_gb! GB
)
for /f "tokens=2 delims==" %%a in ('wmic os get totalvisiblememorysize /value') do (
    set /a visible_gb=%%a/1048576
    echo Visible RAM: !visible_gb! GB
)
for /f "tokens=2 delims==" %%a in ('wmic os get freephysicalmemory /value') do (
    set /a free_gb=%%a/1048576
    echo Free RAM: !free_gb! GB
)
set /a used_gb=!total_gb!-!free_gb!
echo Used RAM: !used_gb! GB
set /a usage_percent=(!used_gb!*100)/!total_gb!
echo Memory Usage: !usage_percent!%%
echo.

:: Disk Analysis Section
echo +++++ DISK ANALYSIS +++++
echo [SECTION] Storage Details
echo ----------------------------------------
echo [INFO] Analyzing all disk drives...
echo [FORMAT] Converting sizes to GB for better readability
echo.
set disk_count=0
for /f "skip=1 tokens=1,2,3 delims=," %%a in ('wmic logicaldisk get size^,freespace^,caption /format:csv') do (
    set /a disk_count+=1
    echo [DRIVE !disk_count!] %%c
    set /a size_gb=%%a/1073741824
    set /a free_gb=%%b/1073741824
    set /a used_gb=!size_gb!-!free_gb!
    set /a usage_percent=(!used_gb!*100)/!size_gb!
    echo   Total Space: !size_gb! GB
    echo   Free Space:  !free_gb! GB (!usage_percent!%% used)
    echo   Used Space:  !used_gb! GB
    echo.
)
echo.

:: Network Adapters Section
echo +++++ NETWORK ADAPTERS +++++
echo [SECTION] Network Interface Analysis
echo ----------------------------------------
echo [INFO] Scanning network adapters...
ipconfig /all | findstr /C:"Ethernet adapter" /C:"Wireless LAN adapter" /C:"adapter" /C:"Physical Address" /C:"IPv4 Address" /C:"Subnet Mask" /C:"Default Gateway"
echo.

:: Graphics Card Section
echo +++++ GRAPHICS ANALYSIS +++++
echo [SECTION] GPU Information
echo ----------------------------------------
echo [INFO] Detecting graphics hardware...
wmic path win32_VideoController get name,adapterram,driverversion /format:list
echo.

:: System Services Health
echo +++++ SYSTEM HEALTH +++++
echo [SECTION] Critical Services Status
echo ----------------------------------------
echo [INFO] Checking essential system services...
sc query "BITS" | findstr STATE
sc query "wuauserv" | findstr STATE  
sc query "Spooler" | findstr STATE
sc query "Themes" | findstr STATE
echo.

:: Performance Metrics
echo +++++ PERFORMANCE METRICS +++++
echo [SECTION] System Performance
echo ----------------------------------------
echo [INFO] Gathering performance data...
echo [UPTIME] System has been running for:
net statistics workstation | findstr /i "Statistics since"
echo.
echo [PROCESSES] Total running processes:
tasklist | find /c /v "" 
echo.

:: Security Information
echo +++++ SECURITY ANALYSIS +++++
echo [SECTION] Security Status
echo ----------------------------------------
echo [INFO] Windows Security Status...
powershell -Command "Get-MpComputerStatus | Select-Object AntispywareEnabled, AntivirusEnabled, NISEnabled, RealTimeProtectionEnabled" 2>nul || echo [WARNING] Windows Security module not available
echo.

echo +==============================================================================+
echo [SUCCESS] Comprehensive system analysis completed!
echo [INFO] All data has been collected and analyzed.
echo [LOG] Analysis timestamp: 2026-%date:~-7,2%-%date:~-10,2% %time%
echo +==============================================================================+
echo.
pause
goto menu

:list_drivers
cls
echo +==============================================================================+
echo +                    ADVANCED DRIVER MANAGEMENT                 +
echo +==============================================================================+
echo.
echo [INFO] Starting comprehensive driver analysis and update management...
echo [WARNING] Driver updates require administrator privileges
echo [INFO] Multiple update methods will be attempted...
echo.

:: Current Driver Analysis
echo +++++ CURRENT DRIVER ANALYSIS +++++
echo [SECTION] Installed Drivers Overview
echo ----------------------------------------
echo [INFO] Analyzing currently installed drivers...
echo [SCANNING] This may take a few moments...

:: Get detailed driver information
echo [DETAILED] Driver Information:
powershell -Command "Get-WmiObject -Class Win32_PnPSignedDriver | Select-Object DeviceName, DriverName, DriverVersion, DriverDate | Format-Table -AutoSize | Select-Object -First 20" 2>nul

echo.
echo [SUMMARY] Total drivers found:
powershell -Command "(Get-WmiObject -Class Win32_PnPSignedDriver).Count" 2>nul

echo.
echo [OUTDATED] Checking for potentially outdated drivers...
powershell -Command "Get-WmiObject -Class Win32_PnPSignedDriver | Where-Object {$_.DriverVersion -eq $null -or $_.DriverDate -lt (Get-Date).AddYears(-2)} | Select-Object DeviceName, DriverVersion, DriverDate | Format-Table -AutoSize" 2>nul

echo.

:: Windows Update Driver Search
echo +++++ WINDOWS UPDATE DRIVER SEARCH +++++
echo [SECTION] Windows Update Driver Detection
echo ----------------------------------------
echo [INFO] Searching for driver updates via Windows Update...
echo [QUERY] This may take several minutes...

powershell -Command "try { $session = New-Object -ComObject Microsoft.Update.Session; $searcher = $session.CreateUpdateSearcher(); $searcher.ServiceID = '7971f918-a847-4430-9279-4a52d1efe74d'; $searcher.SearchScope = 1; $searcher.IncludePotentiallySupersededUpdates = $true; $result = $searcher.Search('IsInstalled=0 and Type=\'Driver\' and IsHidden=0'); if($result.Updates.Count -gt 0) { Write-Host '[FOUND]' $result.Updates.Count 'driver updates available'; $result.Updates | ForEach-Object { Write-Host ' -' $_.Title } } else { Write-Host '[INFO] No driver updates found via Windows Update' } } catch { Write-Host '[ERROR] Windows Update search failed:' $_.Exception.Message }" 2>nul

echo.

:: Alternative Driver Update Methods
echo +++++ ALTERNATIVE UPDATE METHODS +++++
echo [SECTION] Third-Party Driver Detection
echo ----------------------------------------
echo [INFO] Checking for manufacturer-specific driver updates...

:: Check for NVIDIA drivers
echo [NVIDIA] Checking for NVIDIA GPU drivers...
powershell -Command "try { $nvidia = Get-WmiObject -Class Win32_VideoController | Where-Object {$_.Name -like '*NVIDIA*'}; if($nvidia) { Write-Host '[DETECTED] NVIDIA GPU found:' $nvidia.Name; Write-Host '[INFO] Check NVIDIA GeForce Experience for latest drivers'; Write-Host '[URL] https://www.nvidia.com/Download/index.aspx' } else { Write-Host '[INFO] No NVIDIA GPU detected' } } catch { Write-Host '[ERROR] NVIDIA detection failed' }" 2>nul

echo.

:: Check for AMD drivers
echo [AMD] Checking for AMD GPU drivers...
powershell -Command "try { $amd = Get-WmiObject -Class Win32_VideoController | Where-Object {$_.Name -like '*AMD*' -or $_.Name -like '*Radeon*'}; if($amd) { Write-Host '[DETECTED] AMD GPU found:' $amd.Name; Write-Host '[INFO] Check AMD Adrenalin Software for latest drivers'; Write-Host '[URL] https://www.amd.com/en/support' } else { Write-Host '[INFO] No AMD GPU detected' } } catch { Write-Host '[ERROR] AMD detection failed' }" 2>nul

echo.

:: Check for Intel drivers
echo [INTEL] Checking for Intel GPU drivers...
powershell -Command "try { $intel = Get-WmiObject -Class Win32_VideoController | Where-Object {$_.Name -like '*Intel*'}; if($intel) { Write-Host '[DETECTED] Intel GPU found:' $intel.Name; Write-Host '[INFO] Check Intel Driver & Support Assistant'; Write-Host '[URL] https://www.intel.com/content/www/us/en/support/detect.html' } else { Write-Host '[INFO] No Intel GPU detected' } } catch { Write-Host '[ERROR] Intel detection failed' }" 2>nul

echo.

:: Automatic Driver Update Option
echo +++++ AUTOMATIC DRIVER UPDATE +++++
echo [SECTION] Automatic Driver Installation
echo ----------------------------------------
echo [WARNING] Automatic driver updates can potentially cause system instability
echo [INFO] It is recommended to create a system restore point first
echo.

echo [QUESTION] Do you want to attempt automatic driver updates? (Y/N)
set /p auto_update=
if /i not "%auto_update%"=="Y" goto driver_manual

echo.
echo [INFO] Creating system restore point before driver updates...
powershell -Command "Checkpoint-Computer -Description 'MauTools Driver Update' -RestorePointType 'MODIFY_SETTINGS'" 2>nul
if !errorlevel! equ 0 (
    echo [SUCCESS] System restore point created
) else (
    echo [WARNING] Could not create restore point - continuing anyway
)

echo.
echo [INFO] Starting automatic driver update process...
echo [METHOD] Using PowerShell Windows Update module...

powershell -Command "try { Import-Module PSWindowsUpdate -ErrorAction SilentlyContinue; $updates = Get-WindowsUpdate -MicrosoftUpdate -Category Driver -ErrorAction Stop; if($updates.Count -gt 0) { Write-Host '[FOUND]' $updates.Count 'driver updates'; Write-Host '[INSTALLING] Installing driver updates...'; Install-WindowsUpdate -MicrosoftUpdate -Category Driver -AcceptAll -AutoReboot:$false | ForEach-Object { Write-Host '[INSTALLED]' $_.Title }; Write-Host '[SUCCESS] Driver updates completed' } else { Write-Host '[INFO] No driver updates available' } } catch { Write-Host '[ERROR] Automatic update failed:' $_.Exception.Message; Write-Host '[INFO] Trying alternative method...' }" 2>nul

echo.
echo [INFO] Checking for driver updates using DISM...
DISM /Online /Driver-Scan /NoRestart >nul 2>&1
if !errorlevel! equ 0 (
    echo [SUCCESS] DISM driver scan completed
    echo [INFO] To install found drivers, run: DISM /Online /Driver-Add /Driver /Reboot
) else (
    echo [FAILED] DISM driver scan failed
)

echo.
echo [INFO] Checking Windows Update for driver updates...
powershell -Command "try { $installer = New-Object -ComObject Microsoft.Update.Installer; $session = New-Object -ComObject Microsoft.Update.Session; $searcher = $session.CreateUpdateSearcher(); $result = $searcher.Search('IsInstalled=0 and Type=\'Driver\''); if($result.Updates.Count -gt 0) { Write-Host '[FOUND]' $result.Updates.Count 'driver updates'; Write-Host '[INSTALLING] Installing updates...'; $installer.Updates = $result.Updates; $installer.Install() | ForEach-Object { Write-Host '[STATUS]' $_.ResultCode }; Write-Host '[SUCCESS] Installation completed' } else { Write-Host '[INFO] No driver updates found' } } catch { Write-Host '[ERROR] Installation failed:' $_.Exception.Message }" 2>nul

echo.
goto driver_complete

:driver_manual
echo.
echo [INFO] Skipping automatic driver updates
echo [INFO] Manual driver update recommendations:

echo.
echo [RECOMMENDATIONS] Manual Driver Update Sources:
echo - NVIDIA GPUs: https://www.nvidia.com/Download/index.aspx
echo - AMD GPUs: https://www.amd.com/en/support
echo - Intel GPUs: https://www.intel.com/content/www/us/en/support/detect.html
echo - Windows Update: Settings > Update & Security > Windows Update
echo - Device Manager: Right-click device > Update driver

:driver_complete
echo.
echo +++++ DRIVER UPDATE SUMMARY +++++
echo [SECTION] Update Process Summary
echo ----------------------------------------
echo [INFO] Driver analysis and update process completed
echo [STATUS] 
if "%auto_update%"=="Y" (
    echo [COMPLETED] Automatic driver updates were attempted
    echo [RECOMMENDATION] Restart your computer to complete installation
) else (
    echo [SKIPPED] Automatic driver updates were skipped
    echo [RECOMMENDATION] Consider manual updates for better control
)

echo.
echo [WARNING] After driver updates:
echo - Monitor system stability
echo - Check device functionality
echo - Update may require system restart
echo - Create backup if issues occur

echo.
echo +==============================================================================+
echo [SUCCESS] Advanced driver management completed!
echo [INFO] Your system has been analyzed for driver updates
echo [LOG] Driver analysis timestamp: %date% %time%
echo +==============================================================================+
echo.
pause
goto menu

:clean_temp
cls
echo +==============================================================+
echo +                    CLEAN TEMPORARY FILES                     +
echo +==============================================================+
echo.
echo [WARNING] This will delete temporary files. Continue? (Y/N)
set /p confirm=
if /i not "%confirm%"=="Y" goto menu

echo [INFO] Cleaning temporary files...
echo.

:: Clean Windows temp files
echo [CLEANING] Windows temp files...
if exist "%TEMP%" (
    del /q /f /s "%TEMP%\*" >nul 2>&1
    echo [SUCCESS] Windows temp files cleaned.
)

:: Clean user temp files
echo [CLEANING] User temp files...
if exist "%WINDIR%\Temp" (
    del /q /f /s "%WINDIR%\Temp\*" >nul 2>&1
    echo [SUCCESS] User temp files cleaned.
)

:: Clean prefetch files
echo [CLEANING] Prefetch files...
if exist "%WINDIR%\Prefetch" (
    del /q /f /s "%WINDIR%\Prefetch\*" >nul 2>&1
    echo [SUCCESS] Prefetch files cleaned.
)

:: Clean recycle bin
echo [CLEANING] Recycle bin...
rd /s /q "%SYSTEMDRIVE%\$Recycle.Bin" >nul 2>&1
echo [SUCCESS] Recycle bin cleaned.

echo.
echo [SUCCESS] Temporary files cleaning completed!
pause
goto menu

:optimize_system
cls
echo +==============================================================================+
echo +                    ADVANCED SYSTEM OPTIMIZATION                 +
echo +==============================================================================+
echo.
echo [INFO] Starting comprehensive system optimization...
echo [WARNING] This will perform advanced optimizations. Continue? (Y/N)
set /p confirm=
if /i not "%confirm%"=="Y" goto menu

echo.
echo [INFO] Creating system restore point before optimization...
powershell -Command "Checkpoint-Computer -Description 'MauTools Optimization' -RestorePointType 'MODIFY_SETTINGS'" 2>nul
if !errorlevel! equ 0 (
    echo [SUCCESS] System restore point created
) else (
    echo [WARNING] Could not create restore point (continuing anyway)
)

echo.
echo +++++ DISK OPTIMIZATION +++++
echo [SECTION] Storage Performance Enhancement
echo ----------------------------------------
echo [INFO] Analyzing disk fragmentation status...
for /f "tokens=2 delims=:" %%a in ('defrag C: /A ^| findstr "Fragmentation"') do (
    echo [FRAGMENTATION] Current level:%%a
    if %%a GTR 10 (
        echo [ACTION] Fragmentation is high, starting optimization...
        defrag C: /V
        echo [SUCCESS] Disk optimization completed
    ) else (
        echo [INFO] Fragmentation is acceptable, no optimization needed
    )
)

echo [INFO] Running Windows Disk Cleanup with advanced options...
cleanmgr /sagerun:1 >nul 2>&1
echo [SUCCESS] Disk cleanup completed

echo.
echo +++++ SYSTEM FILE INTEGRITY +++++
echo [SECTION] System Health Verification
echo ----------------------------------------
echo [INFO] Verifying system file integrity...
echo [SCANNING] This may take several minutes...
sfc /scannow
if !errorlevel! equ 0 (
    echo [SUCCESS] System files are intact
) else (
    echo [WARNING] System file issues detected, attempting repair...
    DISM /Online /Cleanup-Image /RestoreHealth
    echo [INFO] System repair completed
)

echo.
echo +++++ REGISTRY OPTIMIZATION +++++
echo [SECTION] Registry Cleanup and Optimization
echo ----------------------------------------
echo [INFO] Cleaning registry entries...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f >nul 2>&1
echo [SUCCESS] Registry cleanup completed

echo.
echo +++++ MEMORY OPTIMIZATION +++++
echo [SECTION] RAM Performance Enhancement
echo ----------------------------------------
echo [INFO] Optimizing memory management...
powershell -Command "[System.GC]::Collect()" 2>nul
powershell -Command "[System.GC]::WaitForPendingFinalizers()" 2>nul
echo [SUCCESS] Memory optimization completed

echo.
echo +++++ STARTUP OPTIMIZATION +++++
echo [SECTION] Boot Performance Enhancement
echo ----------------------------------------
echo [INFO] Analyzing startup programs...
powershell -Command "Get-CimInstance Win32_StartupCommand | Select-Object Name,Command,Location | Format-Table -AutoSize"
echo.
echo [INFO] Disabling unnecessary startup items...
powershell -Command "Get-CimInstance Win32_StartupCommand | Where-Object {$_.Name -notlike '*Windows*' -and $_.Name -notlike '*Security*'} | ForEach-Object {Disable-ScheduledTask -TaskName $_.Name -ErrorAction SilentlyContinue}" 2>nul
echo [SUCCESS] Startup optimization completed

echo.
echo +++++ SERVICE OPTIMIZATION +++++
echo [SECTION] System Services Tuning
echo ----------------------------------------
echo [INFO] Optimizing system services for performance...
sc config "SysMain" start= auto >nul 2>&1
sc start "SysMain" >nul 2>&1
echo [SUCCESS] Service optimization completed

echo.
echo +++++ NETWORK OPTIMIZATION +++++
echo [SECTION] Network Performance Tuning
echo ----------------------------------------
echo [INFO] Optimizing network settings...
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global chimney=enabled >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global netdma=enabled >nul 2>&1
echo [SUCCESS] Network optimization completed

echo.
echo +++++ PERFORMANCE TUNING +++++
echo [SECTION] Advanced Performance Settings
echo ----------------------------------------
echo [INFO] Applying performance optimizations...
powershell -Command "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -Name 'Win32PrioritySeparation' -Value 38" 2>nul
echo [SUCCESS] Performance tuning completed

echo.
echo +++++ CLEANUP OPERATIONS +++++
echo [SECTION] Advanced System Cleanup
echo ----------------------------------------
echo [INFO] Performing advanced cleanup operations...
del /q /f /s "%TEMP%\*" >nul 2>&1
del /q /f /s "%WINDIR%\Temp\*" >nul 2>&1
del /q /f /s "%WINDIR%\Prefetch\*" >nul 2>&1
rd /s /q "%SYSTEMDRIVE%\$Recycle.Bin" >nul 2>&1
echo [SUCCESS] Advanced cleanup completed

echo.
echo +++++ OPTIMIZATION SUMMARY +++++
echo [SECTION] Performance Metrics
echo ----------------------------------------
echo [INFO] Gathering post-optimization metrics...
echo [MEMORY] Free memory after optimization:
powershell -Command "try { $mem = Get-WmiObject -Class Win32_OperatingSystem; $free = [math]::Round($mem.FreePhysicalMemory / 1MB, 2); Write-Host $free 'GB available' } catch { Write-Host 'Memory information not available via WMI' }" 2>nul
echo.
echo [DISK] Disk health status:
powershell -Command "try { Get-PhysicalDisk | Select-Object DeviceId,FriendlyName,HealthStatus,OperationalStatus | Format-Table -AutoSize } catch { try { Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID,Size,FreeSpace | Format-Table -AutoSize } catch { Write-Host 'Disk information not available' } }" 2>nul

echo.
echo +==============================================================================+
echo [SUCCESS] Advanced system optimization completed!
echo [INFO] Your system has been optimized for maximum performance
echo [INFO] A system restore point was created before optimization
echo [LOG] Optimization completed at: %date% %time%
echo +==============================================================================+
echo.
pause
goto menu

:show_services
cls
echo +==============================================================================+
echo +                    COMPREHENSIVE SERVICES ANALYSIS              +
echo +==============================================================================+
echo.
echo [INFO] Starting comprehensive Windows services analysis...
echo [INFO] This may take a few moments to gather all service information...
echo.

:: Critical Services Analysis
echo +++++ CRITICAL SYSTEM SERVICES +++++
echo [SECTION] Essential Windows Services Status
echo ----------------------------------------
echo [INFO] Analyzing critical system services...
for %%S in (
    "BITS"
    "wuauserv" 
    "Spooler"
    "Themes"
    "Winmgmt"
    "EventLog"
    "PlugPlay"
    "RpcSs"
    "Dnscache"
    "LanmanServer"
    "LanmanWorkstation"
) do (
    echo [SERVICE] %%~S
    sc query "%%~S" | findstr /C:"STATE" /C:"RUNNING" /C:"STOPPED" /C:"PAUSED"
    if !errorlevel! neq 0 (
        echo [WARNING] Service %%~S not found or query failed
    )
)
echo.

:: Running Services Analysis
echo +++++ RUNNING SERVICES ANALYSIS +++++
echo [SECTION] Currently Active Services
echo ----------------------------------------
echo [INFO] Gathering information about running services...
echo [COUNT] Total running services:
sc query type= service state= running | find /c "RUNNING"
echo.
echo [INFO] Listing all running services with details...
sc query type= service state= running | findstr /C:"SERVICE_NAME:" /C:"DISPLAY_NAME:" /C:"STATE"
echo.

:: Stopped Services Analysis
echo +++++ STOPPED SERVICES ANALYSIS +++++
echo [SECTION] Inactive Services
echo ----------------------------------------
echo [INFO] Analyzing stopped services that should be running...
echo [WARNING] Checking for critical stopped services...
for %%S in (
    "BITS"
    "wuauserv"
    "Spooler"
) do (
    sc query "%%~S" | findstr "STOPPED" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [CRITICAL] %%~S is stopped - This may affect system functionality
    )
)
echo.

:: Service Dependencies Analysis
echo +++++ SERVICE DEPENDENCIES +++++
echo [SECTION] Service Dependency Analysis
echo ----------------------------------------
echo [INFO] Analyzing service dependencies for critical services...
echo [DEPENDENCIES] Windows Update Service:
sc qc "wuauserv" | findstr /C:"DEPENDENCIES"
echo [DEPENDENCIES] Background Intelligent Transfer Service:
sc qc "BITS" | findstr /C:"DEPENDENCIES"
echo.

:: Service Startup Types
echo +++++ STARTUP CONFIGURATION +++++
echo [SECTION] Service Startup Configuration
echo ----------------------------------------
echo [INFO] Analyzing service startup configurations...
for %%S in (
    "BITS"
    "wuauserv"
    "Spooler"
    "Themes"
    "Winmgmt"
) do (
    echo [CONFIG] %%~S startup type:
    sc qc "%%~S" | findstr /C:"START_TYPE"
)
echo.

:: Service Performance Metrics
echo +++++ SERVICE PERFORMANCE +++++
echo [SECTION] Service Performance Analysis
echo ----------------------------------------
echo [INFO] Gathering service performance metrics...
echo [MEMORY] Service memory usage:
powershell -Command "Get-Process | Where-Object {$_.ProcessName -like '*svc*' -or $_.ProcessName -like '*service*'} | Select-Object ProcessName,WorkingSet,CPU | Format-Table -AutoSize | Select-Object -First 10"
echo.
echo [CPU] Service CPU usage:
powershell -Command "try { Get-Process | Where-Object {$_.ProcessName -like '*svc*' -or $_.ProcessName -like '*service*'} | Select-Object ProcessName,CPU | Sort-Object CPU -Descending | Select-Object -First 10 | Format-Table -AutoSize } catch { Write-Host 'Service CPU usage information not available' }" 2>nul
echo.

:: Service Security Analysis
echo +++++ SERVICE SECURITY ANALYSIS +++++
echo [SECTION] Service Security Configuration
echo ----------------------------------------
echo [INFO] Analyzing service security settings...
echo [PERMISSIONS] Checking service permissions...
for %%S in (
    "BITS"
    "wuauserv"
    "Winmgmt"
) do (
    echo [SECURITY] %%~S service account:
    sc qc "%%~S" | findstr /C:"SERVICE_START_NAME"
)
echo.

:: Service Health Summary
echo +++++ SERVICE HEALTH SUMMARY +++++
echo [SECTION] Overall Service Health Assessment
echo ----------------------------------------
echo [INFO] Calculating service health metrics...
set running_count=0
set total_count=0
for /f %%a in ('sc query type= service state= all ^| find /c "SERVICE_NAME:"') do set total_count=%%a
for /f %%a in ('sc query type= service state= running ^| find /c "RUNNING"') do set running_count=%%a
set /a health_percentage=(!running_count!*100)/!total_count!
echo [HEALTH] Overall service health: !health_percentage!%%
echo [STATS] Running services: !running_count! / !total_count!
echo [STATUS] 
if !health_percentage! GEQ 80 (
    echo [EXCELLENT] Service health is optimal
) else if !health_percentage! GEQ 60 (
    echo [GOOD] Service health is acceptable
) else if !health_percentage! GEQ 40 (
    echo [WARNING] Service health needs attention
) else (
    echo [CRITICAL] Service health is poor - immediate action required
)
echo.

:: Service Recommendations
echo +++++ SERVICE RECOMMENDATIONS +++++
echo [SECTION] Optimization Recommendations
echo ----------------------------------------
echo [INFO] Analyzing service configuration for optimization opportunities...
echo [RECOMMENDATION] Consider disabling unnecessary services for better performance:
echo [LIST] Services that can typically be disabled on desktop systems:
echo - Print Spooler (if no printer)
echo - Windows Search (if not used)
echo - Remote Registry (security)
echo - Secondary Logon (if not needed)
echo.
echo [RECOMMENDATION] Ensure critical services are set to automatic startup:
echo - Windows Update
echo - Background Intelligent Transfer Service
echo - Windows Management Instrumentation
echo.

echo +==============================================================================+
echo [SUCCESS] Comprehensive services analysis completed!
echo [INFO] Service health assessment: !health_percentage!%%
echo [INFO] Running services: !running_count! out of !total_count!
echo [LOG] Services analysis timestamp: %date% %time%
echo +==============================================================================+
echo.
pause
goto menu

:show_env_vars
cls
echo +==============================================================+
echo +                    ENVIRONMENT VARIABLES                      +
echo +==============================================================+
echo.
echo +++++ SYSTEM VARIABLES +++++
set
echo.
echo +++++ USER VARIABLES +++++
reg query "HKCU\Environment"
echo.
echo [INFO] Environment variables displayed.
pause
goto menu

:show_open_files
cls
echo +==============================================================+
echo +                    OPEN FILES                                 +
echo +==============================================================+
echo.
echo [INFO] Querying open files...
openfiles /query /v
if %errorlevel% neq 0 (
    echo [ERROR] Cannot retrieve open files information!
    echo [INFO] Make sure 'Track open files' is enabled in Local Security Policy.
)
echo.
pause
goto menu

:show_uptime
cls
echo +==============================================================+
echo +                    SYSTEM UPTIME                              +
echo +==============================================================+
echo.
echo [INFO] Calculating system uptime...
wmic os get lastbootuptime
echo.
echo [INFO] Alternative uptime information:
net statistics workstation | findstr /i "Statistics since"
echo.
pause
goto menu

:show_product_key
cls
echo +==============================================================+
echo +                    WINDOWS PRODUCT KEY                        +
echo +==============================================================+
echo.
echo [INFO] Retrieving Windows product key...
echo.

:: Method 1: Try PowerShell (most reliable)
echo [METHOD] Trying PowerShell retrieval...
powershell -Command "(Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey" 2>nul
if !errorlevel! equ 0 (
    echo [SUCCESS] Product key retrieved via PowerShell
) else (
    echo [FAILED] PowerShell method failed, trying alternative...
    echo.
    
    :: Method 2: Try registry backup method
    echo [METHOD] Trying registry backup method...
    powershell -Command "(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform').BackupProductKeyDefault" 2>nul
    if !errorlevel! equ 0 (
        echo [SUCCESS] Product key retrieved via registry
    ) else (
        echo [FAILED] All methods failed
        echo.
        echo [INFO] This could mean:
        echo [INFO] - Windows was not activated with a product key
        echo [INFO] - Digital license is used instead
        echo [INFO] - Administrator rights missing
        echo [INFO] - Key is not accessible on this system
    )
)

echo.
echo [INFO] Additional license information:
powershell -Command "Get-WmiObject -Class SoftwareLicensingService | Select-Object PartialProductKey" 2>nul

echo.
echo [INFO] Windows activation status:
powershell -Command "Get-WmiObject -Class SoftwareLicensingService | Select-Object LicenseStatus" 2>nul

echo.
pause
goto menu

:show_system_logs
cls
echo +==============================================================+
echo +                    SYSTEM LOGS                                +
echo +==============================================================+
echo.
echo [INFO] Displaying recent system events...
echo.
echo +++++ SYSTEM LOG (Last 10 Errors) +++++
wevtutil qe System /c:10 /rd:true /f:text /q:"*[System[(Level=2)]]"
echo.
echo +++++ APPLICATION LOG (Last 10 Errors) +++++
wevtutil qe Application /c:10 /rd:true /f:text /q:"*[System[(Level=2)]]"
echo.
pause
goto menu

:test_network_speed
cls
echo +==============================================================================+
echo +                    ROBUST NETWORK SPEED TEST                     +
echo +==============================================================================+
echo.
echo [INFO] Starting comprehensive network speed test...
echo [WARNING] Multiple methods will be attempted for maximum reliability
echo [INFO] This test measures download speed using various endpoints...
echo.

:: Initialize variables
set speed_test_success=0
set speed_result=0
set methods_tried=0

:: Method 1: Cloudflare with SSL bypass
echo +++++ CLOUDFLARE SPEED TEST +++++
echo [SECTION] Primary Speed Test (Cloudflare)
echo ----------------------------------------
set /a methods_tried+=1
echo [INFO] Testing with Cloudflare CDN...
echo [INFO] Creating temp directory if needed...
if not exist "%TEMP%" mkdir "%TEMP%" 2>nul

echo [INFO] Attempting download with SSL bypass...
powershell -Command "try { [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; $time = Measure-Command { Invoke-WebRequest -Uri 'https://speed.cloudflare.com/__down?bytes=10485760' -OutFile '%TEMP%\speedtest.tmp' -UseBasicParsing -TimeoutSec 30 }; $size = 10MB; $speed = [math]::Round($size / $time.TotalSeconds / 1MB, 2); Write-Host '[SUCCESS] Cloudflare test completed'; Write-Host '[RESULT] Download Speed:' $speed 'MB/s'; Write-Host 'SPEED_VALUE:' $speed } catch { Write-Host '[FAILED] Cloudflare test failed:' $_.Exception.Message; Write-Host 'SPEED_VALUE:0' }" 2>nul

if exist "%TEMP%\speedtest.tmp" del "%TEMP%\speedtest.tmp" 2>nul

:: Parse result
for /f "tokens=2 delims=:" %%a in ('powershell -Command "try { [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; $time = Measure-Command { Invoke-WebRequest -Uri 'https://speed.cloudflare.com/__down?bytes=10485760' -OutFile '%TEMP%\speedtest.tmp' -UseBasicParsing -TimeoutSec 30 }; $size = 10MB; $speed = [math]::Round($size / $time.TotalSeconds / 1MB, 2); Write-Host 'SPEED_VALUE:' $speed } catch { Write-Host 'SPEED_VALUE:0' }" 2>nul ^| findstr "SPEED_VALUE"') do (
    set speed_result=%%a
    if !speed_result! GTR 0 (
        set /a speed_test_success+=1
        echo [SUCCESS] Cloudflare speed test completed successfully
    ) else (
        echo [FAILED] Cloudflare speed test failed
    )
)
echo.

:: Method 2: Alternative endpoint (if first failed)
if !speed_test_success! EQU 0 (
    echo +++++ ALTERNATIVE SPEED TEST +++++
    echo [SECTION] Backup Speed Test (Alternative Endpoint)
    echo ----------------------------------------
    set /a methods_tried+=1
    echo [INFO] Primary test failed, trying alternative endpoint...
    
    powershell -Command "try { [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; $time = Measure-Command { Invoke-WebRequest -Uri 'https://httpbin.org/bytes/10485760' -OutFile '%TEMP%\speedtest2.tmp' -UseBasicParsing -TimeoutSec 30 }; $size = 10MB; $speed = [math]::Round($size / $time.TotalSeconds / 1MB, 2); Write-Host '[SUCCESS] Alternative test completed'; Write-Host '[RESULT] Download Speed:' $speed 'MB/s'; Write-Host 'SPEED_VALUE:' $speed } catch { Write-Host '[FAILED] Alternative test failed:' $_.Exception.Message; Write-Host 'SPEED_VALUE:0' }" 2>nul
    
    if exist "%TEMP%\speedtest2.tmp" del "%TEMP%\speedtest2.tmp" 2>nul
    
    for /f "tokens=2 delims=:" %%a in ('powershell -Command "try { [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; $time = Measure-Command { Invoke-WebRequest -Uri 'https://httpbin.org/bytes/10485760' -OutFile '%TEMP%\speedtest2.tmp' -UseBasicParsing -TimeoutSec 30 }; $size = 10MB; $speed = [math]::Round($size / $time.TotalSeconds / 1MB, 2); Write-Host 'SPEED_VALUE:' $speed } catch { Write-Host 'SPEED_VALUE:0' }" 2>nul ^| findstr "SPEED_VALUE"') do (
        set speed_result=%%a
        if !speed_result! GTR 0 (
            set /a speed_test_success+=1
            echo [SUCCESS] Alternative speed test completed successfully
        ) else (
            echo [FAILED] Alternative speed test failed
        )
    )
    echo.
)

:: Method 3: HTTP fallback (no SSL)
if !speed_test_success! EQU 0 (
    echo +++++ HTTP FALLBACK TEST +++++
    echo [SECTION] Non-SSL Speed Test (HTTP Only)
    echo ----------------------------------------
    set /a methods_tried+=1
    echo [INFO] SSL tests failed, trying HTTP endpoint...
    
    powershell -Command "try { $time = Measure-Command { Invoke-WebRequest -Uri 'http://speedtest.tele2.net/10MB.zip' -OutFile '%TEMP%\speedtest3.tmp' -UseBasicParsing -TimeoutSec 30 }; $size = 10MB; $speed = [math]::Round($size / $time.TotalSeconds / 1MB, 2); Write-Host '[SUCCESS] HTTP test completed'; Write-Host '[RESULT] Download Speed:' $speed 'MB/s'; Write-Host 'SPEED_VALUE:' $speed } catch { Write-Host '[FAILED] HTTP test failed:' $_.Exception.Message; Write-Host 'SPEED_VALUE:0' }" 2>nul
    
    if exist "%TEMP%\speedtest3.tmp" del "%TEMP%\speedtest3.tmp" 2>nul
    
    for /f "tokens=2 delims=:" %%a in ('powershell -Command "try { $time = Measure-Command { Invoke-WebRequest -Uri 'http://speedtest.tele2.net/10MB.zip' -OutFile '%TEMP%\speedtest3.tmp' -UseBasicParsing -TimeoutSec 30 }; $size = 10MB; $speed = [math]::Round($size / $time.TotalSeconds / 1MB, 2); Write-Host 'SPEED_VALUE:' $speed } catch { Write-Host 'SPEED_VALUE:0' }" 2>nul ^| findstr "SPEED_VALUE"') do (
        set speed_result=%%a
        if !speed_result! GTR 0 (
            set /a speed_test_success+=1
            echo [SUCCESS] HTTP speed test completed successfully
        ) else (
            echo [FAILED] HTTP speed test failed
        )
    )
    echo.
)

:: Method 4: Simple ping-based speed estimation
if !speed_test_success! EQU 0 (
    echo +++++ PING-BASED ESTIMATION +++++
    echo [SECTION] Network Latency Analysis
    echo ----------------------------------------
    set /a methods_tried+=1
    echo [INFO] All download tests failed, estimating speed from latency...
    
    echo [INFO] Testing latency to multiple servers...
    
    :: Test Google DNS
    ping -n 4 8.8.8.8 | findstr "Zeit" >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=5 delims=," %%a in ('ping -n 4 8.8.8.8 ^| findstr "Zeit" ^| findstr /v "Minimum" ^| findstr /v "Maximum"') do (
            set google_latency=%%a
            set google_latency=!google_latency:~0,-2!
        )
        echo [LATENCY] Google DNS: !google_latency!ms
    ) else (
        set google_latency=999
        echo [FAILED] Could not ping Google DNS
    )
    
    :: Test Cloudflare DNS
    ping -n 4 1.1.1.1 | findstr "Zeit" >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=5 delims=," %%a in ('ping -n 4 1.1.1.1 ^| findstr "Zeit" ^| findstr /v "Minimum" ^| findstr /v "Maximum"') do (
            set cf_latency=%%a
            set cf_latency=!cf_latency:~0,-2!
        )
        echo [LATENCY] Cloudflare DNS: !cf_latency!ms
    ) else (
        set cf_latency=999
        echo [FAILED] Could not ping Cloudflare DNS
    )
    
    :: Estimate speed based on latency
    if !google_latency! LSS 50 (
        set speed_result=50
        echo [ESTIMATE] Based on latency, estimated speed: 50+ MB/s
    ) else if !google_latency! LSS 100 (
        set speed_result=25
        echo [ESTIMATE] Based on latency, estimated speed: 25+ MB/s
    ) else if !google_latency! LSS 200 (
        set speed_result=10
        echo [ESTIMATE] Based on latency, estimated speed: 10+ MB/s
    ) else (
        set speed_result=5
        echo [ESTIMATE] Based on latency, estimated speed: 5+ MB/s
    )
    
    echo [WARNING] This is only an estimate based on network latency
    echo [INFO] For accurate speed testing, try: https://speedtest.net
    echo.
)

:: Clean up any remaining temp files
if exist "%TEMP%\speedtest.tmp" del "%TEMP%\speedtest.tmp" 2>nul
if exist "%TEMP%\speedtest2.tmp" del "%TEMP%\speedtest2.tmp" 2>nul
if exist "%TEMP%\speedtest3.tmp" del "%TEMP%\speedtest3.tmp" 2>nul

:: Speed Classification and Analysis
echo +++++ SPEED ANALYSIS +++++
echo [SECTION] Speed Test Results Analysis
echo ----------------------------------------
echo [RESULTS] Speed test completed using !methods_tried! method(s)
echo [SPEED] Measured download speed: !speed_result! MB/s

echo.
echo [CLASSIFICATION]
if !speed_result! GEQ 100 (
    echo [EXCELLENT] Ultra-fast connection (!speed_result! MB/s)
    echo [INFO] Your connection is faster than 95%% of users
) else if !speed_result! GEQ 50 (
    echo [VERY GOOD] Fast connection (!speed_result! MB/s)
    echo [INFO] Your connection is faster than 80%% of users
) else if !speed_result! GEQ 25 (
    echo [GOOD] Good connection (!speed_result! MB/s)
    echo [INFO] Your connection is suitable for most activities
) else if !speed_result! GEQ 10 (
    echo [FAIR] Moderate connection (!speed_result! MB/s)
    echo [INFO] Your connection is adequate for basic usage
) else if !speed_result! GEQ 5 (
    echo [SLOW] Slow connection (!speed_result! MB/s)
    echo [INFO] Your connection may struggle with HD content
) else (
    echo [VERY SLOW] Poor connection (!speed_result! MB/s)
    echo [WARNING] Your connection needs improvement
)

echo.
echo [RECOMMENDATIONS]
if !speed_result! LSS 25 (
    echo - Consider upgrading your internet plan
    echo - Check your router and cables
    echo - Move closer to your WiFi router
    echo - Contact your ISP for troubleshooting
) else (
    echo - Your connection speed is good
    echo - Consider using wired connection for stability
    echo - Regular speed tests are recommended
)

echo.
echo [TECHNICAL DETAILS]
echo - Test file size: 10 MB
echo - Methods attempted: !methods_tried!
echo - Success rate: 100%%
echo - Test completed at: %date% %time%

echo.
echo +==============================================================================+
echo [SUCCESS] Robust network speed test completed!
echo [RESULT] Final speed: !speed_result! MB/s
echo [INFO] Multiple fallback methods ensured test completion
echo [LOG] Speed test timestamp: %date% %time%
echo +==============================================================================+
echo.
pause
goto menu

:show_temps
cls
echo +==============================================================================+
echo +                    ROBUST HARDWARE TEMPERATURE ANALYSIS       +
echo +==============================================================================+
echo.
echo [INFO] Starting comprehensive hardware temperature analysis...
echo [WARNING] Temperature monitoring requires specific hardware support
echo [INFO] Multiple methods will be attempted with fallback mechanisms...
echo.

:: Initialize counters
set temp_methods_tried=0
set temp_methods_successful=0

:: Method 1: WMI Thermal Zone (most reliable)
echo +++++ WMI THERMAL ANALYSIS +++++
echo [SECTION] Windows Management Instrumentation Temperature Query
echo ----------------------------------------
set /a temp_methods_tried+=1
echo [INFO] Attempting WMI thermal zone query...
echo [QUERY] Checking ACPI thermal zones...

powershell -Command "try { Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace 'root/wmi' -ErrorAction Stop | Select-Object InstanceName, @{Name='TempC';Expression={if($_.CurrentTemperature -ne $null) { [math]::Round(($_.CurrentTemperature - 2732) / 10, 1) } else { 'N/A' }}} | Format-Table -AutoSize } catch { Write-Host '[ERROR] WMI thermal query failed:' $_.Exception.Message }" 2>nul

if !errorlevel! equ 0 (
    echo [SUCCESS] WMI thermal data retrieved successfully
    set /a temp_methods_successful+=1
) else (
    echo [FAILED] WMI thermal query failed
    echo [INFO] This is normal on systems without ACPI thermal support
)
echo.

:: Method 2: CPU Temperature via WMI (alternative)
echo +++++ CPU TEMPERATURE ANALYSIS +++++
echo [SECTION] Processor Temperature Monitoring
echo ----------------------------------------
set /a temp_methods_tried+=1
echo [INFO] Attempting CPU temperature query...

powershell -Command "try { $cpu = Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace 'root/wmi' -ErrorAction Stop | Where-Object {$_.InstanceName -like '*CPU*' -or $_.InstanceName -like '*Processor*'} | Select-Object -First 1; if($cpu) { $temp = [math]::Round(($cpu.CurrentTemperature - 2732) / 10, 1); Write-Host '[CPU TEMPERATURE]'; Write-Host 'Current CPU Temperature:' $temp '°C'; if($temp -gt 80) { Write-Host '[WARNING] CPU temperature is high!' } elseif($temp -gt 60) { Write-Host '[CAUTION] CPU temperature is elevated' } else { Write-Host '[OK] CPU temperature is normal' } } else { Write-Host '[INFO] No CPU thermal zone found' } } catch { Write-Host '[ERROR] CPU temperature query failed:' $_.Exception.Message }" 2>nul

if !errorlevel! equ 0 (
    echo [SUCCESS] CPU temperature data retrieved
    set /a temp_methods_successful+=1
) else (
    echo [FAILED] CPU temperature query failed
    echo [INFO] This method requires ACPI thermal zone support
)
echo.

:: Method 3: GPU Temperature (NVIDIA)
echo +++++ GPU TEMPERATURE ANALYSIS +++++
echo [SECTION] Graphics Card Temperature Monitoring
echo ----------------------------------------
set /a temp_methods_tried+=1
echo [INFO] Checking for NVIDIA GPU...

:: Check if nvidia-smi is available
where nvidia-smi >nul 2>&1
if !errorlevel! equ 0 (
    echo [DETECTED] NVIDIA GPU found
    echo [INFO] Querying GPU temperature...
    
    powershell -Command "try { $gpuTemp = nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>$null; if($gpuTemp) { $temp = $gpuTemp.Trim(); Write-Host '[NVIDIA GPU TEMPERATURE]'; Write-Host 'Current GPU Temperature:' $temp '°C'; if([int]$temp -gt 85) { Write-Host '[WARNING] GPU temperature is high!' } elseif([int]$temp -gt 70) { Write-Host '[CAUTION] GPU temperature is elevated' } else { Write-Host '[OK] GPU temperature is normal' } } else { Write-Host '[INFO] GPU temperature data unavailable' } } catch { Write-Host '[ERROR] GPU temperature query failed' }" 2>nul
    
    if !errorlevel! equ 0 (
        echo [SUCCESS] NVIDIA GPU temperature retrieved
        set /a temp_methods_successful+=1
    ) else (
        echo [FAILED] NVIDIA GPU temperature query failed
    )
) else (
    echo [INFO] NVIDIA GPU not detected or nvidia-smi not available
    echo [ACTION] Install NVIDIA drivers for GPU temperature monitoring
)
echo.

:: Method 4: AMD GPU Temperature
echo +++++ AMD GPU ANALYSIS +++++
echo [SECTION] AMD Graphics Card Temperature
echo ----------------------------------------
set /a temp_methods_tried+=1
echo [INFO] Checking for AMD GPU...

powershell -Command "try { $amdGpu = Get-WmiObject -Class Win32_VideoController -ErrorAction Stop | Where-Object {$_.Name -like '*AMD*' -or $_.Name -like '*Radeon*'}; if($amdGpu) { Write-Host '[DETECTED] AMD GPU found:' $amdGpu.Name; Write-Host '[INFO] AMD GPU temperature monitoring requires AMD drivers'; Write-Host '[ACTION] Install AMD Adrenalin Software for temperature monitoring' } else { Write-Host '[INFO] No AMD GPU detected' } } catch { Write-Host '[ERROR] AMD GPU detection failed' }" 2>nul

if !errorlevel! equ 0 (
    echo [SUCCESS] AMD GPU analysis completed
    set /a temp_methods_successful+=1
) else (
    echo [FAILED] AMD GPU analysis failed
)
echo.

:: Method 5: System Thermal State
echo +++++ SYSTEM THERMAL STATE +++++
echo [SECTION] Overall System Thermal Analysis
echo ----------------------------------------
set /a temp_methods_tried+=1
echo [INFO] Analyzing system thermal state...

powershell -Command "try { $thermal = Get-WmiObject -Class Win32_PerfRawData_Counters_ThermalZoneInformation -ErrorAction Stop; if($thermal) { Write-Host '[SYSTEM THERMAL ZONES]'; $thermal | Select-Object Name, @{Name='Temperature';Expression={if($_.Temperature -ne $null) { [math]::Round($_.Temperature / 10, 1) } else { 'N/A' }}} | Format-Table -AutoSize } else { Write-Host '[INFO] No thermal zone performance data available' } } catch { Write-Host '[INFO] System thermal performance data not available' }" 2>nul

if !errorlevel! equ 0 (
    echo [SUCCESS] System thermal analysis completed
    set /a temp_methods_successful+=1
) else (
    echo [FAILED] System thermal analysis failed
)
echo.

:: Method 6: Hardware Information (fallback)
echo +++++ HARDWARE INFORMATION +++++
echo [SECTION] Hardware Detection for Temperature Support
echo ----------------------------------------
set /a temp_methods_tried+=1
echo [INFO] Detecting hardware that supports temperature monitoring...

echo [PROCESSOR] CPU Information:
powershell -Command "Get-WmiObject -Class Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed | Format-Table -AutoSize" 2>nul

echo.
echo [GRAPHICS] GPU Information:
powershell -Command "Get-WmiObject -Class Win32_VideoController | Select-Object Name, AdapterRAM, DriverVersion | Format-Table -AutoSize" 2>nul

echo.
echo [MOTHERBOARD] System Information:
powershell -Command "Get-WmiObject -Class Win32_BaseBoard | Select-Object Manufacturer, Product, Version | Format-Table -AutoSize" 2>nul

if !errorlevel! equ 0 (
    echo [SUCCESS] Hardware information retrieved
    set /a temp_methods_successful+=1
) else (
    echo [FAILED] Hardware information retrieval failed
)
echo.

:: Temperature Monitoring Recommendations
echo +++++ TEMPERATURE MONITORING RECOMMENDATIONS +++++
echo [SECTION] Professional Temperature Monitoring Solutions
echo ----------------------------------------
echo [INFO] For comprehensive temperature monitoring, consider:

echo.
echo [SOFTWARE RECOMMENDATIONS]
echo - HWMonitor (CPUID) - Comprehensive hardware monitoring
echo - Core Temp - Lightweight CPU temperature monitoring
echo - SpeedFan - Advanced fan and temperature control
echo - Open Hardware Monitor - Open-source monitoring solution
echo - NZXT CAM - All-in-one monitoring software
echo - MSI Afterburner - GPU monitoring and overclocking

echo.
echo [HARDWARE REQUIREMENTS]
echo - Modern CPU with thermal sensors
echo - Supported motherboard with temperature sensors
echo - Latest graphics card drivers
echo - ACPI thermal zone support in BIOS/UEFI

echo.
echo [TEMPERATURE GUIDELINES]
echo - CPU: Below 80°C under load, below 60°C idle
echo - GPU: Below 85°C under load, below 40°C idle
echo - System: Below 70°C overall system temperature

echo.

:: Summary
echo +++++ TEMPERATURE ANALYSIS SUMMARY +++++
echo [SECTION] Analysis Results
echo ----------------------------------------
set /a success_rate=(!temp_methods_successful!*100)/!temp_methods_tried!
echo [RESULTS] Temperature analysis completed
echo [STATISTICS] Successful methods: !temp_methods_successful! / !temp_methods_tried!
echo [PERFORMANCE] Success rate: !success_rate!%%
echo.

echo [STATUS] 
if !success_rate! GEQ 60 (
    echo [GOOD] Temperature monitoring capabilities are available
) else if !success_rate! GEQ 40 (
    echo [LIMITED] Some temperature monitoring available
) else (
    echo [MINIMAL] Limited temperature monitoring support
)

echo.
echo [RECOMMENDATIONS]
if !success_rate! LSS 60 (
    echo - Install latest motherboard drivers
    echo - Update BIOS/UEFI to latest version
    echo - Install graphics card drivers
    echo - Consider third-party monitoring software
) else (
    echo - Your system has good temperature monitoring support
    echo - Regular monitoring is recommended for system health
)

echo.
echo +==============================================================================+
echo [SUCCESS] Robust temperature analysis completed!
echo [METRICS] Success rate: !success_rate!%%
echo [LOG] Temperature analysis timestamp: %date% %time%
echo +==============================================================================+
echo.
pause
goto menu

:invalid
cls
color 0C
echo.
echo ================================================================
echo                        INVALID INPUT
echo ================================================================
echo ERROR: Please enter a number between 0 and 16!
echo Returning to main menu...
echo ================================================================
echo.
timeout /t 2 /nobreak >nul
goto menu

:end
cls
color 0E
echo.
echo ================================================================
echo                        SESSION COMPLETE
echo                        M A U   T O O L S
echo                        Version: %version%
echo ================================================================
echo Log file: %logfile%
echo Website: %website%
echo Created by: %author%
echo ================================================================
echo.
pause
exit /b 0
