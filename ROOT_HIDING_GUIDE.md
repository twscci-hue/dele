# Root 环境隐藏方案使用指南

## 功能概述

三角洲痕迹清理工具现已集成完整的 Root 环境隐藏功能，专门针对三角洲行动等游戏的反作弊检测（ACE），提供一站式 Root 隐藏解决方案。

## 主要功能

### 1. Root 环境检测

**功能描述：**
- 自动识别当前 Root 类型（Magisk/KernelSU/APatch）
- 显示 Root 版本信息
- 检测 Zygisk 启用状态
- 统计已安装模块数量
- 检测关键隐藏模块安装情况

**使用方法：**
```
主菜单 → [6] Root环境隐藏方案 → [1] 检测 Root 环境
```

**检测内容：**
- Shamiko (Root 隐藏核心)
- Hide My Applist (应用列表隐藏)
- PlayIntegrityFix (SafetyNet 认证)
- Tricky Store (密钥认证绕过)

---

### 2. 查看隐藏方案

**功能描述：**
根据检测到的 Root 类型，显示推荐的模块搭配组合和详细配置步骤。

**使用方法：**
```
主菜单 → [6] Root环境隐藏方案 → [2] 查看隐藏方案
```

#### Magisk 26+ 终极隐藏方案

**必装模块：**
- ✓ Zygisk（内置，需在设置中启用）
- ✓ Shamiko v1.0+ - 隐藏 Root 核心
- ✓ Hide My Applist (HMAL) - 隐藏应用列表

**推荐模块：**
- ○ PlayIntegrityFix - 通过 SafetyNet/Play Integrity
- ○ Tricky Store - 密钥认证绕过
- ○ LSPosed - 高级 Hook 框架

**配置步骤：**
1. Magisk 设置 → 启用 Zygisk
2. 安装 Shamiko，重启
3. 安装 HMAL，配置黑名单模式
4. 添加游戏到 Denylist
5. 在 HMAL 中隐藏 Magisk 相关应用

#### KernelSU 隐藏方案

**必装模块：**
- ✓ Zygisk Next - KSU 的 Zygisk 实现
- ✓ Shamiko - 配合 Zygisk Next 使用
- ✓ Hide My Applist

**配置步骤：**
1. KernelSU → 安装 Zygisk Next
2. 安装 Shamiko 模块
3. 配置应用管理，取消勾选游戏的 Root 权限
4. 在 HMAL 中隐藏 KSU Manager

#### APatch 隐藏方案

**必装模块：**
- ✓ Cherish Peekaboo - APatch 专用隐藏
- ✓ 内置超级用户管理

**配置步骤：**
1. APatch → 超级用户 → 排除游戏应用
2. 安装 Cherish Peekaboo 模块
3. 配置应用隐藏列表

---

### 3. 一键配置隐藏

**功能描述：**
自动检测当前配置状态，一键完成基础隐藏配置。

**使用方法：**
```
主菜单 → [6] Root环境隐藏方案 → [3] 一键配置隐藏
```

**自动配置项：**
1. 添加三角洲行动到 Magisk Denylist
2. 检测并提示 Shamiko 配置
3. 检测并提示 Hide My Applist 配置
4. 清理常见 Root 痕迹文件

**注意事项：**
- 需要已安装 Magisk
- 模块未安装会给出下载提示
- 配置完成后建议重启设备

---

### 4. 三角洲专项配置

**功能描述：**
针对三角洲行动（Delta Force）的 ACE 反作弊系统，提供专项隐藏配置。

**使用方法：**
```
主菜单 → [6] Root环境隐藏方案 → [4] 三角洲专项配置
```

**支持的游戏版本：**
- com.tencent.tmgp.dfm (国服)
- com.garena.game.codm (台服)
- com.activision.callofduty.shooter (国际服)

**配置检查项：**
1. **Magisk Denylist 配置**
   - 自动添加游戏到 Denylist
   
2. **Hide My Applist 配置**
   - 提示需要隐藏的应用列表：
     * Magisk/KSU Manager
     * 终端模拟器 (Termux 等)
     * Root 管理类应用
     * 修改器/外挂类应用

3. **系统特征隐藏**
   - su 二进制文件
   - Magisk 相关文件
   - /data/adb 目录
   - Root 相关 props

4. **高级配置建议**
   - 启用 Shamiko 白名单模式
   - 配置 Tricky Store 通过设备认证
   - 清理游戏风控数据后再启动

**使用建议：**
1. 重启设备后再启动游戏
2. 首次启动前清理游戏数据
3. 定期检查隐藏模块更新

---

### 5. Root 痕迹清理

**功能描述：**
深度清理系统中的 Root 相关痕迹文件，提升隐藏效果。

**使用方法：**
```
主菜单 → [6] Root环境隐藏方案 → [5] Root 痕迹清理
```

**清理内容：**

1. **Root 痕迹文件**
   - /system/app/Superuser.apk
   - /system/xbin/su
   - /system/bin/su
   - /data/local/tmp/su
   - /sbin/su

2. **Busybox 痕迹**
   - 检测 /system/xbin 可疑符号链接

3. **Hook 框架痕迹**
   - Xposed/LSPosed 残留文件
   - /system/framework/XposedBridge.jar
   - /data/adb/modules/xposed

4. **SELinux 上下文修复**
   - 恢复系统分区正确的安全上下文

5. **系统日志清理**
   - 清理 tombstones
   - 清理 dropbox
   - 清理 logcat

**警告：**
- 此操作可能影响部分 Root 功能
- 建议在需要隐藏 Root 时使用
- 操作前请确认备份重要数据

---

### 6. 模块下载地址

**功能描述：**
显示所有隐藏模块的官方下载链接。

**使用方法：**
```
主菜单 → [6] Root环境隐藏方案 → [6] 模块下载地址
```

**模块列表：**

| 模块名称 | 用途 | 下载地址 |
|---------|------|---------|
| **Shamiko** | Root 隐藏核心 | https://github.com/LSPosed/LSPosed.github.io/releases |
| **Hide My Applist** | 应用列表隐藏 | https://github.com/Dr-TSNG/Hide-My-Applist/releases |
| **PlayIntegrityFix** | 完整性修复 | https://github.com/chiteroman/PlayIntegrityFix/releases |
| **Tricky Store** | 密钥认证绕过 | https://github.com/5ec1cff/TrickyStore/releases |
| **Zygisk Next** | KernelSU 专用 | https://github.com/Dr-TSNG/ZygiskNext/releases |
| **Cherish Peekaboo** | APatch 专用 | https://github.com/kikacc/Cherish-Peekaboo/releases |

**注意事项：**
1. 请从官方 GitHub 下载模块
2. 安装后需重启设备
3. 不同 Root 方案需要不同模块

---

## 使用流程推荐

### 首次配置流程

1. **检测 Root 环境**
   ```
   [6] Root环境隐藏方案 → [1] 检测 Root 环境
   ```
   了解当前 Root 类型和已安装模块

2. **查看隐藏方案**
   ```
   [6] Root环境隐藏方案 → [2] 查看隐藏方案
   ```
   根据 Root 类型查看推荐配置

3. **下载必要模块**
   ```
   [6] Root环境隐藏方案 → [6] 模块下载地址
   ```
   下载并安装缺少的模块

4. **一键配置隐藏**
   ```
   [6] Root环境隐藏方案 → [3] 一键配置隐藏
   ```
   自动配置基础隐藏设置

5. **三角洲专项配置**
   ```
   [6] Root环境隐藏方案 → [4] 三角洲专项配置
   ```
   针对游戏进行专项配置

6. **清理 Root 痕迹**
   ```
   [6] Root环境隐藏方案 → [5] Root 痕迹清理
   ```
   深度清理残留痕迹

7. **重启设备**
   完成所有配置后重启设备使配置生效

---

## 支持的游戏

### 三角洲行动（重点支持）
- **国服**: com.tencent.tmgp.dfm
- **台服**: com.garena.game.codm
- **国际服**: com.activision.callofduty.shooter

### 其他游戏
- **暗区突围**
  - 国服: com.tencent.tmgp.aqtw
  - 台服: com.netease.aqtw.tw
  - 国际服: com.netease.aqtw

- **王者荣耀**
  - 国服: com.tencent.tmgp.sgame

- **和平精英**
  - 国服: com.tencent.tmgp.pubgmhd

---

## 常见问题

### Q1: 为什么一键配置后游戏仍检测到 Root？

**A:** 可能原因：
1. 未安装必要的隐藏模块（Shamiko、HMAL）
2. 未在 Hide My Applist 中配置黑名单
3. 未重启设备使配置生效
4. 需要清理游戏数据重新启动

**解决方案：**
- 检查所有必装模块是否已安装
- 确认 Hide My Applist 中已正确配置
- 使用"三角洲专项配置"进行详细检查
- 重启设备后再启动游戏

### Q2: Magisk Denylist 添加游戏后无效？

**A:** 可能原因：
1. 未启用 Zygisk
2. 未安装 Shamiko 模块
3. Hide My Applist 配置不完整

**解决方案：**
- Magisk 设置 → 启用 Zygisk → 重启
- 安装 Shamiko 模块 → 重启
- 配置 Hide My Applist 黑名单模式

### Q3: KernelSU 如何隐藏 Root？

**A:** KernelSU 隐藏步骤：
1. 安装 Zygisk Next 模块
2. 安装 Shamiko 模块
3. KSU 应用管理 → 取消游戏的 Root 权限
4. 安装 Hide My Applist 并配置

### Q4: Root 痕迹清理会影响正常使用吗？

**A:** 
- 清理操作主要删除常见 Root 特征文件
- 不会影响 Magisk/KernelSU 核心功能
- Shamiko 等模块会继续工作
- 建议在需要时使用，而非频繁清理

### Q5: 如何验证隐藏是否成功？

**A:** 验证方法：
1. 使用"Root 环境检测"查看配置状态
2. 启动游戏测试是否被封禁
3. 使用 Root 检测应用测试（如 SafetyNet Helper）
4. 观察游戏是否有异常行为

---

## 技术支持

- **闲鱼**: @WuTa
- **版本**: 1.0.0
- **最后更新**: 2025-12-05

---

## 免责声明

1. 本工具仅供学习交流使用
2. 使用本工具所造成的任何后果由使用者自行承担
3. Root 设备存在安全风险，请谨慎操作
4. 游戏账号安全由用户自行负责
5. 建议在虚拟机或测试设备上先行测试

---

## 更新日志

### v1.0.0 (2025-12-05)
- ✨ 新增 Root 环境检测功能
- ✨ 新增隐藏方案展示（Magisk/KernelSU/APatch）
- ✨ 新增一键配置隐藏功能
- ✨ 新增三角洲专项配置
- ✨ 新增 Root 痕迹深度清理
- ✨ 新增模块下载地址汇总
- ✨ 完整的中文界面和提示
- ✨ 集成到主菜单系统

---

## 贡献者

感谢以下开源项目：
- [Magisk](https://github.com/topjohnwu/Magisk)
- [KernelSU](https://github.com/tiann/KernelSU)
- [APatch](https://github.com/bmax121/APatch)
- [Shamiko](https://github.com/LSPosed/LSPosed.github.io)
- [Hide My Applist](https://github.com/Dr-TSNG/Hide-My-Applist)

---

**注意**: 请遵守游戏服务条款，合理使用 Root 权限。
