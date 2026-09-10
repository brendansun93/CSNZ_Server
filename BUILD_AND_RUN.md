# CSNZ 本地私服与启动器构建运行与开发指南

本文档详细记录了 **CSNZ_Server**（服务端）与 **Launcher_CSNZ**（客户端启动器）的编译、配置、运行流程，以及后续开发迭代后的重新编译与部署步骤。

---

## 目录
1. [环境前置要求](#1-环境前置要求)
2. [依赖库初始化 (Git Submodules)](#2-依赖库初始化-git-submodules)
3. [客户端启动器编译 (Launcher_CSNZ)](#3-客户端启动器编译-launcher_csnz)
4. [服务端程序编译 (CSNZ_Server)](#4-服务端程序编译-csnz_server)
5. [客户端与服务端部署](#5-客户端与服务端部署)
6. [运行与联机测试](#6-运行与联机测试)
7. [日常开发迭代与重新编译工作流](#7-日常开发迭代与重新编译工作流)
8. [常见问题排查 (FAQ)](#8-常见问题排查-faq)

---

## 1. 环境前置要求

| 工具/依赖 | 推荐版本 | 说明 |
| :--- | :--- | :--- |
| **Visual Studio** | 2019 或 2022 (Community 版即可) | 必须勾选 **"使用 C++ 的桌面开发"** 工作负载，且支持 **x86 (32位)** 与 **x64 (64位)** 编译 |
| **CMake** | 3.16 及以上 | 用于生成 `CSNZ_Server` 构建工程 |
| **Git** | 2.20 及以上 | 用于管理代码与同步第三方子模块 |
| **VC++ 运行库** | 2015-2022 Redistributable (x86 & x64) | 确保游戏引擎与服务端能正常运行 |
| **CSNZ 客户端本体** | Counter-Strike Nexon: Studio / Zombies | 官方完整游戏目录（包含 `Bin/`、`nar/`、`hw.dll` 等） |
| **Qt (可选)** | 6.5.3 (MSVC 64位) | 仅在需要编译带有图形界面的服务端监控器时需要 |

---

## 2. 依赖库初始化 (Git Submodules)

服务端 `CSNZ_Server` 依赖于多个开源第三方库（`SQLiteCpp`、`nlohmann/json`、`wolfssl`、`zip`、`rapidcsv`、`doctest`、`KeyValues`）。

首次拉取项目或重新克隆后，在 `CSNZ_Server` 根目录执行：

```bash
cd d:\工作室\CSNZ_Server
git submodule update --init --recursive
```

> **注意**：如果更新后子模块有缺失，可再次执行上述命令。

---

## 3. 客户端启动器编译 (Launcher_CSNZ)

`Launcher_CSNZ` 是一个 32 位的 Hook 引导程序，用于劫持 GoldSrc 引擎的连接并绕过 Nexon 反作弊。

### 方式 A：通过 Visual Studio IDE 编译
1. 打开 `d:\工作室\Launcher_CSNZ\CSOLauncher.sln`。
2. 在顶部工具栏中设置构建模式：
   * **配置 (Configuration)**：`Release`
   * **平台 (Platform)**：`x86` / `Win32`（**严禁选 x64**，CSO 引擎核心 `hw.dll` 为 32 位）。
3. 菜单栏选择 **生成 -> 生成解决方案** (Build Solution)。
4. 编译产物位于：`Launcher_CSNZ\Release\CSOLauncher.exe`。

### 方式 B：通过 MSBuild 命令行编译
在开发者 PowerShell / CMD（VS Developer Command Prompt）中执行：
```cmd
cd d:\工作室\Launcher_CSNZ
msbuild CSOLauncher.sln /p:Configuration=Release /p:Platform=x86
```

---

## 4. 服务端程序编译 (CSNZ_Server)

### 编译控制台版服务端（推荐，最轻量稳定）

1. 进入源码目录并使用 CMake 生成构建工程：
   ```cmd
   cd d:\工作室\CSNZ_Server\src
   cmake -S . -B build -A x64
   ```
   *(如果想编译 32 位版本，可使用 `-A Win32`)*

2. 执行编译：
   ```cmd
   cmake --build build --config Release
   ```
3. 编译完成后，可执行文件 `CSNZ_Server.exe` 会生成在 `src/build/Release/`（或 `src/build/bin/`）目录下。

### 编译 Qt GUI 监控版服务端（可选）
1. 确保系统安装了 Qt 6.5.3 并设置了环境变量 `QTDIR`（例如：`C:\Qt\6.5.3\msvc2019_64`）。
2. 在 CMake 配置时启用 GUI 选项后编译即可。

---

## 5. 客户端与服务端部署

编译生成后，需要将生成的文件部署到对应的运行环境中：

### 1. 部署客户端启动器
将生成的 `CSOLauncher.exe` 复制到 **CSNZ 客户端本体的 `Bin` 目录** 下：
```text
[游戏客户端根目录]
  ├── Bin/
  │    ├── CSOLauncher.exe    <-- 放置在此处
  │    ├── hw.dll             <-- 官方引擎
  │    ├── filesystem_nar.dll <-- 官方虚拟文件系统
  │    └── ...
  ├── cstrike/
  └── Data/
```

### 2. 部署服务端运行环境
服务端运行依赖于 `CSNZ_Server/bin/` 目录中的配置文件与数据表。

确保运行目录结构如下：
```text
[Server运行目录] (例如 CSNZ_Server/bin/)
  ├── CSNZ_Server.exe         <-- 编译出来的服务端程序放置在此
  ├── ServerConfig.json       <-- 主配置文件
  ├── Data/                   <-- 元数据表（Item.csv, MapList.csv 等）
  │    ├── SQL/
  │    │    └── main.sql      <-- 数据库初始化脚本
  │    ├── Item.csv
  │    ├── MapList.csv
  │    └── ...
  └── UserDatabase.db3        <-- 首次运行后会自动生成此 SQLite 数据库
```

---

## 6. 运行与联机测试

### 1. 启动服务端
直接双击运行 `CSNZ_Server.exe`（或在控制台中启动）。
* **首次启动**：服务端会自动解析 `Data/` 目录下的 CSV 表格并执行 `SQL/main.sql` 生成 `UserDatabase.db3`。
* 观察控制台输出，确认提示 `TCP Server listening on port 30002`。

### 2. 启动客户端
进入游戏目录的 `Bin` 文件夹，使用命令行或创建快捷方式运行：
```cmd
CSOLauncher.exe -ip 127.0.0.1 -port 30002
```

#### 常用启动参数列表：
| 参数 | 说明 | 示例 / 默认值 |
| :--- | :--- | :--- |
| `-ip <IP>` | 指定主服务器 IP | `-ip 127.0.0.1` |
| `-port <Port>` | 指定主服务器端口 | `-port 30002` |
| `-login <User>` | 自动登录指定账号（跳过登录弹窗） | `-login player1` |
| `-password <Pwd>` | 自动登录密码 | `-password 123456` |
| `-debug` / `-dev` | 开启游戏控制台与调试输出 | `-debug` |
| `-nomutex` | 允许多开游戏客户端（测试联机用） | `-nomutex` |
| `-loaddedicsvfromfile` | 从 `CSNZ\Data` 读取专用服务器 CSV | 用于调试专用服务器属性 |

---

## 7. 日常开发迭代与重新编译工作流

当您后续修改了代码、调整了配置或增加了新特性时，请遵循以下流程：

### 场景 1：修改了服务端代码 (`CSNZ_Server/src/...`)
1. 修改 C++ 源码或网络包处理逻辑。
2. 执行增量构建：
   ```cmd
   cd d:\工作室\CSNZ_Server\src
   cmake --build build --config Release
   ```
3. 退出正在运行的旧 `CSNZ_Server.exe`。
4. 将新生成的 `CSNZ_Server.exe` 覆盖到运行目录。
5. 重新启动服务端测试。

### 场景 2：修改了数据表 / 道具 / 掉落率 (`CSNZ_Server/bin/Data/...`)
1. 修改 `Data/Item.csv` 或 `ServerConfig.json`。
2. 无需重新编译 C++ 源码，直接在服务端控制台输入重载指令（或重启服务端）即可生效。

### 场景 3：修改了客户端 Hook 逻辑 (`Launcher_CSNZ/...`)
1. 修改 `hook.cpp`、`launcher.cpp` 等。
2. Visual Studio 按 `Ctrl+Shift+B` 重新生成 `Release | x86`。
3. 关闭游戏，将新生成的 `CSOLauncher.exe` 覆盖到客户端 `Bin` 目录。
4. 重新启动游戏测试。

### 场景 4：Git 代码提交与推送到个人 Fork 仓库
本地已关联您的个人 Fork 仓库（`origin`），开发完成后提交代码：
```bash
# 1. 查看修改文件
git status

# 2. 暂存与提交
git add .
git commit -m "描述您的修改，如：优化网络同步逻辑/修复商城购买异常"

# 3. 推送至个人 GitHub 仓库
git push origin master
```

---

## 8. 常见问题排查 (FAQ)

### Q1: 启动游戏提示 `Could not load engine: hw.dll` 或 `filesystem_nar.dll`？
* **原因**：`CSOLauncher.exe` 没有放置在游戏客户端的 `Bin` 目录中。
* **解决**：务必将 `CSOLauncher.exe` 放到 `CSNZ\Bin\` 下运行，而不是在源码编译目录直接运行。

### Q2: 客户端启动后闪退，或者提示内存错误？
* **原因**：启动器编译成了 64 位，或者缺少 VC++ 2015-2022 x86 运行库。
* **解决**：确保 `CSOLauncher.vcxproj` 严格以 **Release / x86** 模式编译。

### Q3: 登录时提示连接服务器失败？
* **原因**：`CSNZ_Server.exe` 未启动，或者防火墙拦截了 `30002` 端口。
* **解决**：检查服务端是否正常监听 `30002` 端口；本地测试请确保参数为 `-ip 127.0.0.1 -port 30002`。

### Q4: 如何重置数据库 / 清理所有玩家数据？
* **解决**：关闭服务端后，直接删除运行目录下的 `UserDatabase.db3` 文件，下次启动时会自动重新生成全新的初始数据库。
