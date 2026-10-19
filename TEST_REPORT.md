# V1.6.2 RC1 初步测试补充（2026-10-19）

| 检查项 | 状态 | 依据 |
| --- | --- | --- |
| 新采集卡兼容性 BUG | 用户初步确认已修复 | 用户明确反馈“初步测试完成，修复了一个兼容性的 BUG” |
| 设备 A/B 与错误源匹配 | 模拟测试通过 | Chromium 模拟 MediaStream/设备 ID，A/B 正确匹配，错配拒绝 |
| 真实 A→B→A 全链路 | 待逐项归档 | 暂无每个设备与模式的独立测试记录 |
| 录制、帧复制、Chrome/Edge、热插拔 | 待完整回归 | 暂未逐项确认 |

> 本补充不代表正式版本验收。以下保留 V1.6.1 历史报告。

# USB Capture Web Viewer V1.6.1 RC7 — 本地测试

**状态：本地候选版，未上传 GitHub；Windows 11 / 真正 UVC 设备需实测。**

环境：Linux Chromium（Playwright）+ Canvas 模拟 HDMI 视频流；剪贴板与 WebM 保存使用模拟权限接口，但 PNG 字节与录制输出字节非空已验证。

## 已验证
- 顶栏黑色背景全宽且四角为直角（CSS `border-radius:0`）；两行分组标题左端严格对齐，在 1440 px 时两行末端也对齐，900/420 px 时按行横向滚动。
- 定位控制确实进入第二行，缩放仅保留百分比。
- 锁定时鼠标离开不隐藏；解锁后鼠标离开隐藏、移到顶部重新显示。
- 半透明背景 64% 不透明度，按钮与文字不整体降低透明度；状态按钮独立。
- 双击右键与 Ctrl+C 截帧（PNG 实际尺寸）和录制时截帧。
- 采集约束变更不新增摄像头申请。
- 完整 WebM 录制/停止保存模拟流程。

## 局限与未验证
- 运行环境限制访问网络 URL 与 `file://`，不能在此环境复现 Windows 固定 localhost 的浏览器跨重启存储；本次仅验证透明度及锁定开关的 DOM/CSS 状态和浏览器事件响应。
- 真正 Windows / Edge / Chrome 的 localhost localStorage 跨重启设置保持、鼠标右键实际按键时序、UVC 实机编码及录制路径。

```json
[
  {
    "viewport": "1440x810",
    "full_width_background": "PASS",
    "left_title": "PASS",
    "two_rows": "PASS",
    "focus_second_row": "PASS",
    "lock_always_visible": "PASS",
    "unlock_hover_hide": "PASS",
    "opacity_0_64": "PASS",
    "right_double_png": "PASS",
    "ctrl_c": "PASS",
    "zoom": "PASS",
    "applyConstraints_without_reauth": "PASS",
    "record": "PASS",
    "errors": []
  },
  {
    "viewport": "900x560",
    "full_width_background": "PASS",
    "left_title": "PASS",
    "two_rows": "PASS",
    "focus_second_row": "PASS",
    "lock_always_visible": "PASS",
    "unlock_hover_hide": "PASS",
    "opacity_0_64": "PASS",
    "right_double_png": "PASS",
    "ctrl_c": "PASS",
    "zoom": "PASS",
    "applyConstraints_without_reauth": "PASS",
    "record": "not run",
    "errors": []
  },
  {
    "viewport": "420x640",
    "full_width_background": "PASS",
    "left_title": "PASS",
    "two_rows": "PASS",
    "focus_second_row": "PASS",
    "lock_always_visible": "PASS",
    "unlock_hover_hide": "PASS",
    "opacity_0_64": "PASS",
    "right_double_png": "PASS",
    "ctrl_c": "PASS",
    "zoom": "PASS",
    "applyConstraints_without_reauth": "PASS",
    "record": "not run",
    "errors": []
  }
]
```
