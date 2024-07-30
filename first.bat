@echo off
setlocal

REM 步骤 1: 检查 Git 是否已安装
echo 正在检查 Git 是否已安装...
git --version > nul 2>&1
if %errorlevel% equ 0 (
    echo Git 已安装。
) else (
    echo Git 未安装，正在下载并安装 Git...
    
    REM 设置 Git 的下载链接和安装路径
    set GIT_URL=https://github.com/git-for-windows/git/releases/download/v2.39.1.windows.1/Git-2.39.1-64-bit.exe
    set INSTALLER_PATH=%TEMP%\Git-Installer.exe
    
    REM 下载 Git 安装程序
    echo 下载 Git 安装程序...
    powershell -Command "Invoke-WebRequest -Uri %GIT_URL% -OutFile %INSTALLER_PATH%"

    REM 安装 Git
    echo 安装 Git...
    start /wait %INSTALLER_PATH% /VERYSILENT /NORESTART

    REM 检查 Git 是否安装成功
    git --version > nul 2>&1
    if %errorlevel% equ 0 (
        echo Git 安装成功。
    ) else (
        echo Git 安装失败，请手动安装 Git。
        exit /b 1
    )
)

REM 步骤 2: 生成 SSH 密钥对
echo 正在生成 SSH 密钥对...
set /p email="请输入您的电子邮箱地址作为 SSH 密钥的标签: "
ssh-keygen -t rsa -b 4096 -C "%email%" -f %USERPROFILE%\.ssh\id_rsa -N ""

REM 检查密钥生成是否成功
if exist %USERPROFILE%\.ssh\id_rsa (
    echo SSH 密钥对生成成功。
) else (
    echo 生成 SSH 密钥对失败。
    exit /b 1
)

REM 步骤 3: 将公钥添加到 Git 服务器
echo 正在将公钥复制到剪贴板...
type %USERPROFILE%\.ssh\id_rsa.pub | clip

echo 公钥已复制到剪贴板。请将其添加到您的 Git 服务器。
echo 按照以下说明添加 SSH 密钥：

echo 对于 GitHub：
echo - 进入设置 > SSH 和 GPG 密钥 > 新建 SSH 密钥
echo - 将密钥粘贴到“密钥”字段并保存。

echo 对于 GitLab：
echo - 进入用户设置 > SSH 密钥
echo - 将密钥粘贴到“密钥”字段并保存。

pause

REM 步骤 4: 配置 SSH 客户端
echo 正在配置 SSH 客户端...

echo Host github.com >> %USERPROFILE%\.ssh\config
echo     User git >> %USERPROFILE%\.ssh\config
echo     IdentityFile %USERPROFILE%\.ssh\id_rsa >> %USERPROFILE%\.ssh\config

echo SSH 客户端配置成功。

pause
endlocal
