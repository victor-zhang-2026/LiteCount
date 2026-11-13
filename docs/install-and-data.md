# 安装与数据 / Install and data

## 系统要求 / Requirements

- macOS 14.0 或更高 / macOS 14.0 or later
- Apple Silicon（arm64）/ Apple Silicon (arm64)

## 安装 / Install

1. 从 [Releases](https://github.com/victor-zhang-2026/LiteCount/releases/latest) 下载最新 `LiteCount-<版本>-macOS-arm64.zip` 与 `SHA256SUMS`。
   Download the latest ZIP and SHA256SUMS from Releases.
2. 校验完整性 / Verify integrity:

   ```bash
   shasum -a 256 -c SHA256SUMS
   ```

3. 解压 `LiteCount.app`。
   Unzip `LiteCount.app`.
4. 首次启动：安装包为 ad-hoc 签名、未经 Apple 公证。首次打开请在 Finder 中右键点击 App →「打开」；之后可正常双击启动。
   First launch: the bundle is ad-hoc signed and not notarized. Right-click the app and choose Open the first time.
5. 首次设置到期前提醒时，应用会请求系统通知权限，请选择允许。若此前拒绝，请前往「系统设置 → 通知 → LiteCount」，开启「允许通知」。[Apple 通知设置说明](https://support.apple.com/guide/mac-help/change-notifications-settings-mchl205da693/mac)。
   The first time you set a reminder, allow LiteCount to send notifications. If you previously denied permission, enable Allow Notifications in System Settings → Notifications → LiteCount. [Apple's notification settings guide](https://support.apple.com/guide/mac-help/change-notifications-settings-mchl205da693/mac).

## 数据存储 / Data

- 所有事项与设置保存在 `~/Library/Application Support/LiteCount/items.json`，更新前自动写一份 `items.backup.json`。
  Items and settings live in `~/Library/Application Support/LiteCount/items.json`, with an automatic `items.backup.json` before each update write.
- 卸载应用不会删除该目录；如需彻底清除请手动删除。
  Uninstalling the app does not remove this directory; delete it manually for a full cleanup.
- 文件为未加密 JSON；「本地」不等于额外加密或访问隔离，请自行纳入备份策略。
  Files are unencrypted JSON; local storage is not an encryption layer, so include it in your own backup routine.

## 悬浮球 / Floating ball

- 拖动可改变位置，位置按显示器记忆（支持合盖与外接屏变化）。
  Drag to reposition; positions are remembered per display.
- 右键菜单仅提供「退出 LiteCount」，退出前有确认。
  The right-click menu offers Quit with a confirmation.

## 已知边界 / Known limits

- 未做 Apple 公证（notarization）；Gatekeeper 首次打开需右键 → 打开。
- 数据无云同步；换机需手动迁移上述 JSON 文件。
- 到期事项保留在列表中显示「已到期」，不会自动删除。
- 提醒由 macOS 本地通知处理；系统专注模式和通知设置可能影响展示。
