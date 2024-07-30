@echo off
setlocal

REM 步骤 1: 生成 SSH 密钥对
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

REM 步骤 2: 将公钥添加到 Git 服务器
echo 正在将公钥复制到剪贴板...
type %USERPROFILE%\.ssh\id_rsa.pub | clip

echo 公钥已复制到剪贴板。请将其添加到您的 Git 服务器。
echo 按照以下说明添加 SSH 密钥：

echo 请自行访问 GitHub：
echo - 进入设置 > SSH 和 GPG 密钥 > 新建 SSH 密钥
echo - 将密钥粘贴到“密钥”字段并保存。


pause

REM 步骤 3: 配置 SSH 客户端
echo 正在配置 SSH 客户端...

echo Host github.com >> %USERPROFILE%\.ssh\config
echo     User git >> %USERPROFILE%\.ssh\config
echo     IdentityFile %USERPROFILE%\.ssh\id_rsa >> %USERPROFILE%\.ssh\config

echo SSH 客户端配置成功。

pause
endlocal
