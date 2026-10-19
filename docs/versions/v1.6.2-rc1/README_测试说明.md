# USB Capture Web Viewer · V1.6.2 RC1 测试说明

版本：2026-10-19，用户初步实机验证确认修复至少一项采集卡兼容性问题；仍属 RC 候选版。

## 运行

下载或克隆本仓库，运行 `Start_Chrome_Snap.cmd`（Edge 可使用 `Start_Edge_Snap.cmd`）。首次启动允许浏览器访问摄像头。关闭 OBS、Windows 相机等可能占用采集卡的程序。

## 核心修复

1. 指定设备使用 `deviceId:{exact:id}`。
2. 视频轨道 ID 与选定设备不一致时停止播放并报错。
3. 参数不兼容仅回退同一采集设备的自动模式。
4. 使用 `usbCaptureDiagnostics()` 获取当前源 ID/状态。

## 待回归

真实双卡 A→B→A 切换、同名设备、热插拔、录制、权限保存、Chrome/Edge 交叉测试。

未在真实设备上确认完整回归之前，不升格为 V1.6.2 正式稳定版。
