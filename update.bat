@echo off
setlocal enabledelayedexpansion

REM 检查并创建 update.c 文件
if not exist update.c (
    echo // This is the update.c file. > update.c
)

REM 获取当前时间并编码为 Base64
for /f "tokens=1-5 delims=:. " %%a in ("%date% %time%") do (
    set now=%%a %%b %%c %%d %%e
)
echo %now% > temp_time.txt
certutil -encode temp_time.txt temp_time.b64 >nul
for /f "skip=1 delims=" %%a in (temp_time.b64) do (
    set encoded_time=%%a
    goto done
)
:done
del temp_time.txt temp_time.b64

REM 将编码后的时间追加到 update.c
echo // %encoded_time% >> update.c

REM Git 操作
git add update.c
git pull origin main
git commit -m "Update update.c with current time"
git push origin main

endlocal
pause
