# dele - 三角洲痕迹清理工具

集成高级自毁机制和代码保护的专业清理工具。

## 功能特性

- 下发文件检测
- 深度环境监测
- 基础文件清理
- 设备硬件标识变更
- 全维深度核心清理
- 自动版本检测和自毁机制

## 代码保护机制

本项目采用双重保护机制防止源码泄露：

1. **混淆层**：变量名、函数名替换为无意义字符，删除注释
2. **编译层**：Shell 脚本编译为 ELF 二进制，无法直接查看
3. **加密层**：shc 使用 RC4 加密脚本内容

## 使用方法

### 直接使用源码（开发模式）

```bash
# 需要 Root 权限
su
bash dele.sh
```

### 使用编译保护版本

#### 方式1: 从 Release 下载

1. 访问 [Releases](https://github.com/twscci-hue/dele/releases) 页面
2. 下载最新的 `dele-arm64` 二进制文件
3. 传输到设备并运行：

```bash
# 传输到手机
adb push dele-arm64 /data/local/tmp/

# 进入手机shell
adb shell
su

# 运行
chmod +x /data/local/tmp/dele-arm64
/data/local/tmp/dele-arm64
```

#### 方式2: 本地编译

```bash
# 1. 安装依赖
sudo apt install shc

# 2. 运行编译脚本
chmod +x tools/build.sh
./tools/build.sh

# 3. 输出文件位于 build/dele
```

## 编译保护版本

### 自动编译

推送代码到 `main` 分支或创建 tag 时，GitHub Actions 会自动：

1. 混淆源代码
2. 编译为 ARM64 二进制文件
3. 上传到 Release（仅 tag 触发）

### 本地编译说明

**系统要求：**
- Linux 操作系统（Ubuntu/Debian 推荐）
- shc 编译器

**编译步骤：**

```bash
# 安装 shc
sudo apt install shc

# 运行编译脚本
chmod +x tools/build.sh
./tools/build.sh
```

编译后的二进制文件位于 `build/dele`

## 项目结构

```
dele/
├── .github/
│   └── workflows/
│       └── build.yml        # GitHub Actions 自动编译
├── tools/
│   ├── obfuscate.sh         # 混淆脚本
│   └── build.sh             # 本地编译脚本
├── build/                   # 编译输出目录 (gitignore)
├── dele.sh                  # 源代码
├── README.md                # 项目说明
└── .gitignore               # 忽略编译产物
```

## 技术支持

如有问题，请联系：@闲鱼:WuTa

## 注意事项

- 需要 Root 权限运行
- 操作有风险，请谨慎清理
- 数据丢失后果自负
- 建议使用前先备份重要数据

## 版本检测

工具内置版本检测功能，会在启动时自动检查更新。如果版本过低，程序会在退出时自动自毁，请及时获取最新版本。

## 保护效果

通过混淆和编译双重保护，即使有人尝试反编译，也只能看到混淆后的代码，大大增加了逆向难度。

- **反编译难度**：⭐⭐⭐⭐⭐
- **代码可读性**：⭐ (编译后几乎不可读)
- **安全性**：⭐⭐⭐⭐⭐
