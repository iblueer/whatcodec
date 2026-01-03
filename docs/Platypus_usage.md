# Platypus 命令行工具使用

Q: 这个项目能不能通过shell或者http之类的方式访问？我不想使用图形界面，而是通过sh脚本或者py脚本将固定的工作流保存下来。
A: 可以。完全支持命令行操作，而且这个功能就是为你这种场景设计的。

## 命令行工具使用

Platypus自带 `platypus` 命令行工具（在 `CLT/` 目录下实现），可以直接在shell脚本中使用，无需GUI。它支持与图形界面相同的所有功能，包括应用打包、配置管理等。

### 基本用法

```bash
# 最简单的应用打包
platypus script.py MyApp.app

# 指定解释器和应用名称
platypus -a "MyApp" -p /usr/bin/python3 script.py MyApp.app

# 创建无界面的后台应用
platypus -o None -B script.py MyApp.app
```

### 保存和重用工作流（关键功能）

这正是你需要的功能。Platypus使用"配置文件（Profile）"机制：

```bash
# 保存当前配置为profile（.platypus文件）
platypus -O script.py myworkflow.platypus

# 从profile加载配置并生成应用
platypus -P myworkflow.platypus MyApp.app

# profile可以传递参数覆盖
platypus -P myworkflow.platypus -o "Text Window" MyApp.app
```

### 完整工作流示例

```bash
#!/bin/bash
# deploy.sh - 自动化打包脚本

# 定义变量
SCRIPT="myapp.py"
APP_NAME="MyApp"
PROFILE="myapp_profile.platypus"

# 如果profile不存在，创建一个
if [ ! -f "$PROFILE" ]; then
    platypus -O \
        -a "$APP_NAME" \
        -o "Status Menu" \
        -p /usr/bin/python3 \
        -f config.json \
        -f assets/logo.icns \
        "$SCRIPT" \
        "$PROFILE"
fi

# 从profile生成最终应用
platypus -P "$PROFILE" "build/$APP_NAME.app"
```

### Python集成示例

```python
import subprocess

# 定义配置
config = {
    'name': 'MyApp',
    'interpreter': '/usr/bin/python3',
    'interface': 'Status Menu',
    'author': 'Your Name',
    'version': '1.0',
    'bundle_id': 'com.example.myapp'
}

# 生成profile
cmd = ['platypus', '-O', '-a', config['name'], 
       '-p', config['interpreter'],
       '-o', config['interface'],
       '-u', config['author'],
       '-V', config['version'],
       '-I', config['bundle_id'],
       'script.py', 'myapp.platypus']

subprocess.run(cmd)

# 从profile生成应用
subprocess.run(['platypus', '-P', 'myapp.platypus', 'MyApp.app'])
```

## 关于HTTP访问

Platypus本身不提供HTTP接口，但你可以：
1. 将Platypus生成的应用作为HTTP API的执行后端
2. 使用命令行工具在服务器端自动化打包
3. 集成到CI/CD流程中

### 参考资源

- [命令行工具完整文档](13-command-line-tool-reference)
- [配置文件格式规范](https://sveinbjorn.org/files/manpages/platypus.man.html)
- [示例应用目录](Examples/) - 包含22个现成的.platypus配置文件

## 配置文件结构

看看示例就明白了，比如 [ProgressBar.platypus](Examples/ProgressBar.platypus)，这是一个标准的XML属性列表文件，包含所有应用配置参数。你可以：
- 手动编辑（虽然是XML，但结构清晰）
- 用命令行生成后修改
- 版本控制管理不同环境的配置

这种设计让你可以完全抛弃GUI，用纯脚本驱动整个构建流程。

## 如何安装

Q: 单纯下载了 release 的 app，是不是没法直接用 cli工具？ 如何安装cli 工具？
A: 是的，release 的 app 不会自动安装 CLI 工具到系统路径。你需要手动安装，有两种方式：

### 方法一：通过 Platypus 应用界面安装（推荐）

1. 打开 Platypus 应用
2. 点击菜单 **Platypus → Preferences**
3. 找到 **"Install Command Line Tool"** 选项并勾选
4. 应用会自动将 `platypus` 命令安装到 `/usr/local/bin/platypus`

这是最简单的方法，应用会自动处理权限和文件复制。

### 方法二：手动运行安装脚本

如果你想在脚本中自动化安装：

```bash
# 以管理员权限运行安装脚本
sudo /Applications/Platypus.app/Contents/Resources/InstallCommandLineTool.sh \
  /Applications/Platypus.app/Contents/Resources
```

这个脚本会：
- 创建 `/usr/local/bin`、`/usr/local/share/platypus` 等目录
- 将 `platypus` 可执行文件安装到 `/usr/local/bin/platypus`
- 安装 man page 到 `/usr/local/share/man/man1/platypus.1`
- 安装 ScriptExec 到 `/usr/local/share/platypus/`

### 验证安装

```bash
# 检查是否安装成功
which platypus

# 查看版本
platypus --version

# 查看帮助
platypus --help
```

### 安装位置

CLI 工具会安装到以下位置（参见 [Common.h](Common.h#L106-L115)）：

```
/usr/local/bin/platypus                    # 命令行工具
/usr/local/share/platypus/                 # 共享资源
/usr/local/share/platypus/ScriptExec       # 执行器
/usr/local/share/man/man1/platypus.1       # 帮助文档
```

### 卸载

如果以后想卸载：

```bash
sudo rm /usr/local/bin/platypus
sudo rm -rf /usr/local/share/platypus
sudo rm /usr/local/share/man/man1/platypus.1*
```

---

安装完成后，你就可以直接在终端中使用 `platypus` 命令了，无需打开 GUI。
