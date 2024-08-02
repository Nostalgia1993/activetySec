@echo off
setlocal

REM === 设置和重置代码页 ===
chcp 65001 > nul

REM === 检查 Git 是否已安装 ===
echo 正在检查 Git 是否已安装...
git --version >nul 2>&1
if %errorlevel% equ 0 (
    echo Git 已安装。
) else (
    echo Git 未安装，请手动下载并安装 Git：https://github.com/git-for-windows/git/releases/download/v2.46.0.windows.1/Git-2.46.0-64-bit.exe
    pause
    exit /b 1
)

@REM pause

REM === 检查 .ssh 目录是否存在 ===
if not exist "%USERPROFILE%\.ssh" (
    echo .ssh 目录不存在，正在创建...
    mkdir "%USERPROFILE%\.ssh"
    if not exist "%USERPROFILE%\.ssh" (
        echo 创建 .ssh 目录失败。
        pause
        exit /b 1
    )
)

REM === 生成 SSH 密钥对 ===
echo 正在生成 SSH 密钥对...
set /p email="请输入您的电子邮箱地址(任意自己的有效邮箱都可以): "
ssh-keygen -t rsa -b 4096 -C "%email%" -f "%USERPROFILE%\.ssh\id_rsa" -N "" 
git config --global user.email "%email%"
git config --global user.name "updater"
if exist "%USERPROFILE%\.ssh\id_rsa" (
    echo SSH 密钥对生成成功。
) else (
    echo 生成 SSH 密钥对失败。
    type "%TEMP%\ssh_keygen_output.txt"
    pause
    exit /b 1
)
chcp 65001 > nul


REM === 将公钥复制到剪贴板 ===
echo 正在将公钥复制到剪贴板...
type "%USERPROFILE%\.ssh\id_rsa.pub" | clip
if %errorlevel% equ 0 (
    echo 公钥已复制到剪贴板。请将其添加到您的 GitHub 个人设置中。
    echo   
    echo   
    echo ----------------------------------
    chcp 65001 > nul
    echo 按照以下说明添加SSH密钥

    echo - 进入设置 - SSH 和 GPG 密钥 - 新建 SSH 密钥
    echo - 将密钥粘贴到“密钥”字段并保存。
    echo ----------------------------------
    echo   
    echo   

) else (
    echo 复制公钥到剪贴板失败。
    pause
    exit /b 1
)

@REM pause

REM === 配置 SSH 客户端 ===
echo 正在配置 SSH 客户端...

set "configFile=%USERPROFILE%\.ssh\config"

REM 创建 config 文件并写入配置
if not exist "%configFile%" (
    echo Host github.com > "%configFile%"
    echo     User git >> "%configFile%"
    echo     IdentityFile "%USERPROFILE%\.ssh\id_rsa" >> "%configFile%"
) else (
    echo SSH 配置文件已存在，检查配置并进行添加...

    findstr /C:"Host github.com" "%configFile%" > nul
    if %errorlevel% neq 0 (
        echo Host github.com >> "%configFile%"
        echo     User git >> "%configFile%"
        echo     IdentityFile "%USERPROFILE%\.ssh\id_rsa" >> "%configFile%"
    ) else (
        findstr /C:"    User git" "%configFile%" > nul
        if %errorlevel% neq 0 (
            echo     User git >> "%configFile%"
        )

        findstr /C:"    IdentityFile %USERPROFILE%\.ssh\id_rsa" "%configFile%" > nul
        if %errorlevel% neq 0 (
            echo     IdentityFile "%USERPROFILE%\.ssh\id_rsa" >> "%configFile%"
        )
    )
)

echo SSH 客户端配置成功。

pause
endlocal

