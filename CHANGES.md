# CSNZ_Server 自定义改动与维护记录

本文档记录针对 **CSNZ_Server**（服务端）相较于上游开源仓库的实际功能改进、工程优化与文档规范。

---

## 1. 构建系统与工程配置优化

- **CMake 构建脚本完善 (`src/CMakeLists.txt`, `src/thirdparty/CMakeLists.txt`)**：
  - 优化了 MSVC x64 构建配置，修正第三方库的链接依赖与目标输出路径。
- **自动化构建脚本 (`install_build_tools.bat`)**：
  - 新增一键环境构建与依赖检查脚本。
- **Git 规则优化 (`.gitignore`)**：
  - 完善对 CMake 缓存（`build/`）、Visual Studio 临时文件、编译中间件及 SQLite 生成数据库的忽略规则。

---

## 2. 模式映射与生化玩法优化

- **模式 24（Bot 生化）映射与参数下发 (`src/room/roomsettings.cpp`)**：
  - 将客户端创建/加入房间时请求的模式 24 底层映射为模式 8（Zombie Classic），规避官方原版模式 24 的僵尸开局与配额踢人限制；
  - 同时在服务端为模式 24 设置 `friendlyBots = 9, enemyBots = 0, lowMidFlag |= ROOM_LOWMID_BOT`（正常模式 8 保持 `friendlyBots = 0`），使客户端启动器能够通过房间网络包精准识别并全自动添加 9 个人类 Bot。

---

## 3. 文档与规范

- **开发与部署指南 (`BUILD_AND_RUN.md`)**：
  - 提供从环境搭建、子模块初始化、CMake 编译到部署运行的完整标准化操作文档。
