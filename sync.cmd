@echo off
setlocal
title IntelliJ Settings Sync
cls

:: copy this script to temp dir and execute it, so that we can safely update the working copy without breaking execution.
if "%1"=="copiedFrom" goto script-copied
set copiedScript=%temp%\incub8-sync-intellij-settings.cmd
copy /y %~f0 %copiedScript% > nul
%copiedScript% copiedFrom %~dp0
:: as we did not use 'call', original script execution ends here.

:script-copied
cd %2

for /f %%i in ('git symbolic-ref --short HEAD') do set currentBranch=%%i
if "%currentBranch%"=="master" goto begin
color e0 && cls
echo.
echo   +------------------------+
echo   ^| You are not on master. ^|
echo   +------------------------+
echo.
echo For safety reasons, this script does not continue.
goto wait

:begin


:check-for-unstaged
git diff --exit-code > nul 2>&1
if not errorlevel 1 goto ensure-connection
color e0 && cls
echo.
echo   +----------------------------+
echo   ^| You have unstaged changes. ^|
echo   +----------------------------+
goto wait

:ensure-connection
echo Waiting for internet connection...
set tries=0
:ping
ping -n 2 8.8.8.8 > nul 2>&1
if not errorlevel 1 goto check-for-staged
set /a tries+=1
if %tries% leq 45 goto ping
color 4f && cls
echo.
echo   +-------------------------+
echo   ^| You seem to be offline. ^|
echo   +-------------------------+
goto wait



:check-for-staged
cls
git diff --cached --exit-code > nul 2>&1
if not errorlevel 1 goto fetch
color e0 && cls
echo.
echo   +--------------------------+
echo   ^| You have staged changes. ^|
echo   +--------------------------+
goto wait

:: Note that we do not check for new, untracked files. As our .gitignore is set to '*', such files would be ignored anyway.


:fetch
for /f %%i in ('git rev-parse --short master') do set oldMaster=%%i
echo Fetching remote changes...

git fetch origin > nul 2>&1
if not errorlevel 1 goto rebase
color 4f && cls
echo.
echo   +---------------------------------+
echo   ^| Could not fetch remote changes. ^|
echo   +---------------------------------+
echo.
echo Is Bitbucket down? Has the repository moved?
goto wait


:rebase
for /f %%i in ('git rev-parse --short origin/master') do set remoteMaster=%%i

git rebase > nul 2>&1
if not errorlevel 1 goto check-rebase-result

git rebase --abort > nul 2>&1
color 4f && cls
echo.
echo   +--------------------------------+
echo   ^| Beware, merge conflicts ahead! ^|
echo   +--------------------------------+
echo.
echo The working copy was reset to your original commit, %oldMaster%.
echo Examine master and origin/master to clear up the situation.
goto wait


:check-rebase-result
for /f %%i in ('git rev-parse --short master') do set newMaster=%%i
if %oldMaster%==%newMaster% goto master-not-moved
if %newMaster%==%remoteMaster% goto fast-forwarded
set message=Rebased local changes, %oldMaster% is now %newMaster%.
echo %message%
echo %date% %time% %message% >> sync.log
goto pushable-commits-found


:fast-forwarded
set message=Fast-forwarded from %oldMaster% to %newMaster%.
echo %message%
echo %date% %time% %message% >> sync.log
goto exit


:master-not-moved
if not %newMaster%==%remoteMaster% goto pushable-commits-found
goto exit


:pushable-commits-found
color 2f && cls
echo.
echo   +---------------------------+
echo   ^| You have commits to push. ^|
echo   +---------------------------+
echo.
git log --no-color origin/master..master
goto wait


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
goto exit

:wait
echo.
echo.
echo Press any key to dismiss.
pause > nul 2>&1


:exit
cls
color
endlocal