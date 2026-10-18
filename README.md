# USB Capture Web Viewer

一个用于 Windows 11 的轻量级 HDMI → USB 视频采集卡预览工具。使用 HTML、浏览器摄像头接口与 PowerShell 启动脚本，适合将树莓派等设备的 HDMI 输出显示在 Windows 桌面的一块独立区域中。

> 当前版本：**v1.4.1**（Windows PowerShell 编码兼容性修复版）。目前仅做过静态检查，未在所有 Windows 11 / Chrome 环境下实机验证。

## 功能

- 通过 Chrome 或 Edge 读取 Windows 已识别的 USB 采集设备；不需要树莓派端安装额外软件。
- 独立应用窗口：隐藏浏览器标签页和地址栏；**保留 Windows 原生标题栏和可调整窗口边框**，以支持 Win11 贴靠布局（Snap Layouts）。
- 自动寻找竖屏，首次启动时默认放置在其底部约 **34%** 的工作区域；之后可以使用鼠标或 Win + Z 调整。
- 请求自动 / 1080P / 720P / 480P，以及 60 / 30 FPS；实际格式以采集卡及浏览器协商结果为准。
- 画面显示模式：完整显示、裁剪铺满、拉伸铺满；缩放范围 100%–220%。
- 视频控制栏仅在鼠标触及画面顶部时显示，离开后立即隐藏。
- 视频本地直接预览，不经远程转码或网络中转。

## 系统要求

- Windows 11（贴靠布局），Windows 10 可尝试普通窗口方式使用。
- Google Chrome（默认）或 Microsoft Edge。
- Windows 可识别的 UVC USB 采集卡与 HDMI 视频源。
- 允许浏览器使用摄像头。

## 快速开始

1. 将本仓库文件下载到同一个文件夹，不要单独移动脚本或 HTML。
2. 接好 HDMI 视频源 → USB 采集卡 → Windows 电脑。
3. 双击 `Start_Chrome_Snap.cmd`。
4. 允许摄像头访问权限，在顶部控制栏选择 USB 采集设备并点击“启动预览”。
5. 悬停 Windows 最大化按钮，或按 `Win + Z`，使用 Windows 11 的原生贴靠布局。也可以直接拖动窗口边缘更改大小。

> **注意**：此版本不是完全去掉系统边框。为保留原生 Snap Layouts，窗口仍具有 Windows 标题栏；但不显示 Chrome 的标签页与地址栏。

## 参数配置

PowerShell 启动脚本：`Launch_USB_Capture_Snap_V1.4.ps1`。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Launch_USB_Capture_Snap_V1.4.ps1 -Browser Chrome -HeightPercent 34
```

| 参数 | 默认值 | 用途 |
| --- | --- | --- |
| `-Browser` | `Chrome` | 可设为 `Chrome`、`Edge` 或 `Auto`。`Auto` 优先 Chrome。 |
| `-HeightPercent` | `34` | 首次启动窗口占目标屏幕工作高度的比例，允许 20–90。 |
| `-MonitorIndex` | `-1` | `-1` 表示优先选择第一块竖屏，否则选择主屏；非负数指定屏幕序号。 |

该脚本使用 Windows API 定位窗口，但不会移除原生可调整窗口边框。

## 常见问题

**预览没有画面**：检查 HDMI 源是否输出、USB 采集卡在 Windows“相机”中是否可用、浏览器的摄像头授权，以及采集卡是否被其他软件独占。

**实际分辨率 / 帧率与选择不同**：页面请求的是期望值，最终取决于采集卡能力与浏览器协商结果；状态栏显示当前实际参数。

**Windows 原生贴靠布局不弹出**：确保是 Windows 11，窗口没有进入网页全屏，且系统设置中启用了窗口贴靠；鼠标停留在窗口右上角的最大化按钮或使用 `Win + Z`。

**首次启动出现旧设备权限设置**：独立 Chrome 用户数据目录位于 `%LOCALAPPDATA%\USB_Capture_Snap_Profile`；其中保存浏览器授权与配置，不应提交到仓库。

**PowerShell 语法错误或中文乱码**：请使用 v1.4.1 或更新版本，其 `.ps1` 采用 UTF-8 BOM 以兼容 Windows PowerShell 5.1。

## 文件说明

```text
USB_Capture_Web_Viewer_V1.4.html    # 视频采集和界面源码
Launch_USB_Capture_Snap_V1.4.ps1   # Windows 窗口启动与初始定位
Start_Chrome_Snap.cmd              # 双击启动入口
README.md                          # 使用说明
CHANGELOG.md                       # 版本历史
.gitignore                         # 忽略本地缓存与配置
```

## 隐私和限制

视频画面使用浏览器的 `getUserMedia()` API 在本机预览，本项目本身不设置上传服务器或云端账号，也不采集用户数据。浏览器授权及设备驱动行为由操作系统和浏览器管理。

本仓库仅提供程序源码与脚本；不包含私人的测试截图、电脑路径或浏览器配置数据。尚未选择开源许可证；若计划允许他人再分发、修改或商用，应另行添加明确的许可证。
