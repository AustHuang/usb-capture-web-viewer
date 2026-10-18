# USB Capture Web Viewer

一个用于 Windows 11 的轻量级 HDMI → USB 视频采集卡预览工具。使用 HTML、浏览器摄像头接口与 PowerShell 启动脚本，适合将树莓派等设备的 HDMI 输出显示在 Windows 桌面的一块独立区域中。

> 当前版本：**v1.6.0**（新增 USB 视频录制）。源码已通过静态检查，尚需在真实 UVC 采集卡、Windows 11、Chrome / Edge 环境下验证录制与文件保存。

## 功能

- 通过 Chrome 或 Edge 读取 Windows 已识别的 USB 采集设备；不需要树莓派端安装额外软件。
- 独立应用窗口：隐藏浏览器标签页和地址栏；**保留 Windows 原生标题栏和可调整窗口边框**，以支持 Win11 贴靠布局（Snap Layouts）。
- 自动寻找竖屏，首次启动时默认放置在其底部约 **34%** 的工作区域；之后可以使用鼠标或 Win + Z 调整。
- 请求自动 / 1080P / 720P / 480P，以及 60 / 30 FPS；实际格式以采集卡及浏览器协商结果为准。
- 画面显示模式：完整显示、裁剪铺满、拉伸铺满；缩放范围 100%–400%。
- 视频控制栏仅在鼠标触及画面顶部时显示，离开后立即隐藏。
- 视频本地直接预览，不经远程转码或网络中转。
- **V1.6** 新增开始/停止录制、REC 计时指示、4/8/16 Mbps 目标码率与本地 WebM 保存。

## V1.6 视频录制

1. 启动预览，确认 USB 采集画面正常。
2. 在顶部工具栏选择录制码率：**4 / 8 / 16 Mbps**（默认 8 Mbps；实际码率由编码器决定）。
3. 点击 **● 开始录制**。Chrome / Edge 支持 File System Access API 时，先选择保存路径和文件名，再开始录制；文件名默认 `USB_Capture_YYYYMMDD_HHMMSS.webm`。
4. 右下角显示 **REC 和录制时长**。录制期间可以继续缩放、拖动和贴靠窗口。
5. 点击 **■ 停止录制**，等候文件写入完成提示。建议再停止预览或关闭窗口。

- **录制源**：原始 UVC / HDMI 视频流，**不是**窗口画面；不包含缩放、平移、顶部工具栏或 REC 标记。
- **视频容器与编码**：WebM，优先 VP8；具体画质、实际 FPS 由采集卡与浏览器编码能力决定。本版不提供 MP4，也不录制 HDMI 音频。
- **本地写入**：支持 `showSaveFilePicker` 时每秒提交媒体分片并顺序写入文件；不支持时，先缓存在浏览器内存，停止后触发 WebM 下载。后者不适合长时间录制。
- **异常保护**：停止预览会先停止录制并完成保存；采集设备断开时也会尝试完成保存。**直接关闭窗口、断电或浏览器崩溃仍可能损坏文件**，请先点击停止录制。
- **容量估算**：8 Mbps 的理论视频负载约为每小时 3.6 GB，实际文件受内容、编码器和文件封装开销影响。
- **隐私**：录制在本机完成，不会上传视频；录制文件不应提交到 GitHub。

## V1.5 画面平移与缩放

- **拖动查看**：放大后，将鼠标移动到视频区域，按住左键拖动，即可移动画面内容。原来放大后只能查看中心附近的局限已解决。
- **滚轮缩放**：在视频画面上滚动滚轮，画面围绕鼠标所在位置放大或缩小，方便迅速放大某个终端字符或角落。
- **四角定位**：顶部控制栏的「查看」下拉菜单可选择左上、右上、左下、右下或居中。选择之后可继续手动微调。
- **居中按钮**：只归零平移量，不改变缩放倍率；「重置」会恢复 100% 和完整显示。
- **方向键微调**：非输入控件获得焦点时，方向键每次移动约 50px。
- **边界限制**：平移量被限制在内容可见的合法范围内，改变窗口尺寸或切换显示模式后自动校正。
- **视频平移不改变采集参数**：本功能仅控制浏览器的视频显示变换，不调整采集卡的分辨率、帧率或缓存。

## 版本管理

本仓库采用 **main 最新版 + release 分支存档** 的方式：

| 分支 | 内容 | 用途 |
| --- | --- | --- |
| `main` | 最新正式版本（目前 V1.6） | 日常下载与后续更新 |
| `release/v1.4.1` | V1.4.1 历史快照 | 旧版下载和回退 |
| `release/v1.5.0` | V1.5.0 历史快照 | 对应版本的固定源码 |
| `release/v1.6.0` | V1.6.0 历史快照 | 对应版本的固定源码 |

- 下载最新版：[main ZIP](https://github.com/AustHuang/usb-capture-web-viewer/archive/refs/heads/main.zip)。
- 下载 V1.4.1：[V1.4.1 ZIP](https://github.com/AustHuang/usb-capture-web-viewer/archive/refs/heads/release/v1.4.1.zip)。
- 下载 V1.5.0：[V1.5.0 ZIP](https://github.com/AustHuang/usb-capture-web-viewer/archive/refs/heads/release/v1.5.0.zip)。
- 下载 V1.6.0：[V1.6.0 ZIP](https://github.com/AustHuang/usb-capture-web-viewer/archive/refs/heads/release/v1.6.0.zip)。

**主分支只保留最新版本的可运行文件**；历史版本从 release 分支获取，而不是在根目录同时放多个编号文件。今后新版本应先在功能分支开发和验证，再合并到 main，最后创建该版本的独立快照分支。若后续需要 GitHub Releases 和语义版本标签，可在相同提交上补充不可变 tag。

## 系统要求

- Windows 11（贴靠布局），Windows 10 可尝试普通窗口方式使用。
- Google Chrome（默认）或 Microsoft Edge。
- Windows 可识别的 UVC USB 采集卡与 HDMI 视频源。
- 允许浏览器使用摄像头。

## 快速开始

1. 将本仓库文件下载到同一个文件夹，不要单独移动脚本或 HTML。
2. 接好 HDMI 视频源 → USB 采集卡 → Windows 电脑。
3. 双击 `Start_Chrome_Snap.cmd`。
4. 允许摄像头访问权限，在顶部控制栏选择 USB 采集设备并点击“启动预览”。如果需要录像，选择码率并点击“开始录制”，选择保存位置。
5. 悬停 Windows 最大化按钮，或按 `Win + Z`，使用 Windows 11 的原生贴靠布局。也可以直接拖动窗口边缘更改大小。

> **注意**：此版本不是完全去掉系统边框。为保留原生 Snap Layouts，窗口仍具有 Windows 标题栏；但不显示 Chrome 的标签页与地址栏。

## 参数配置

PowerShell 启动脚本：`Launch_USB_Capture_Snap.ps1`。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Launch_USB_Capture_Snap.ps1 -Browser Chrome -HeightPercent 34
```

| 参数 | 默认值 | 用途 |
| --- | --- | --- |
| `-Browser` | `Chrome` | 可设为 `Chrome`、`Edge` 或 `Auto`。`Auto` 优先 Chrome。 |
| `-HeightPercent` | `34` | 首次启动窗口占目标屏幕工作高度的比例，允许 20–90。 |
| `-MonitorIndex` | `-1` | `-1` 表示优先选择第一块竖屏，否则选择主屏；非负数指定屏幕序号。 |

该脚本使用 Windows API 定位窗口，但不会移除原生可调整窗口边框。

## 常见问题

**预览没有画面**：检查 HDMI 源是否输出、USB 采集卡在 Windows“相机”中是否可用、浏览器的摄像头授权，以及采集卡是否被其他软件独占。

**录制后找不到文件**：支持直接文件保存时，查看开始录制时选择的路径；下载回退模式请查看浏览器默认下载文件夹。WebM 可用 VLC 或支持该格式的播放器打开。

**实际分辨率 / 帧率与选择不同**：页面请求的是期望值，最终取决于采集卡能力与浏览器协商结果；状态栏显示当前实际参数。

**Windows 原生贴靠布局不弹出**：确保是 Windows 11，窗口没有进入网页全屏，且系统设置中启用了窗口贴靠；鼠标停留在窗口右上角的最大化按钮或使用 `Win + Z`。

**首次启动出现旧设备权限设置**：独立 Chrome 用户数据目录位于 `%LOCALAPPDATA%\USB_Capture_Snap_Profile`；其中保存浏览器授权与配置，不应提交到仓库。

**PowerShell 语法错误或中文乱码**：请使用 v1.4.1 或更新版本，其 `.ps1` 采用 UTF-8 BOM 以兼容 Windows PowerShell 5.1。

## 文件说明

```text
USB_Capture_Web_Viewer.html      # 当前版本 HTML，后续保持文件名稳定
Launch_USB_Capture_Snap.ps1     # 当前版本 Windows 启动与窗口控制
Start_Chrome_Snap.cmd           # 当前版本双击启动
README.md                       # 使用说明
CHANGELOG.md                    # 更新记录
.gitignore                      # 本地配置排除
```

## 隐私和限制

视频画面使用浏览器的 `getUserMedia()` API 在本机预览，视频录制使用 `MediaRecorder` 在本机编码并保存。本项目本身不设置上传服务器或云端账号，也不采集用户数据。浏览器授权及设备驱动行为由操作系统和浏览器管理。

本仓库仅提供程序源码与脚本；不包含私人的测试截图、电脑路径或浏览器配置数据。尚未选择开源许可证；若计划允许他人再分发、修改或商用，应另行添加明确的许可证。
