# 数据与隐私 / Data and privacy

LiteCount 无账号、服务器、联网业务、遥测、分析和广告。只有在用户为事项设置到期前提醒时，应用才请求 macOS 通知权限；不申请联系人、日历、辅助功能等权限。

LiteCount has no accounts, server, networking, telemetry, analytics, or advertising. It requests macOS notification permission only when you set a reminder; it does not request contacts, calendar, or accessibility access.

## 存储位置 / Storage

- 事项数据与设置：`~/Library/Application Support/LiteCount/items.json`（未加密 JSON）+ 自动备份 `items.backup.json`。
  Items and settings: `~/Library/Application Support/LiteCount/items.json` (unencrypted JSON) with an automatic `items.backup.json`.
- 悬浮球位置等偏好：本机 `UserDefaults`。
  Ball position and preferences: local UserDefaults.
- 提醒由 macOS 本地通知中心安排，不发送至服务器；应用不访问摄像头、麦克风或屏幕内容。
  Reminders are scheduled through macOS local notifications, with no server delivery. The app does not access the camera, microphone, or screen content.

## 边界说明 / Limits

- 本地存储不等于加密或访问隔离：本机用户、备份工具与有文件访问权限的软件仍可读取文件，请自行保留备份。
  Local storage is not encryption or access control: other local users or tools with file access can read the files. Keep your own backups.
- 无自动云备份；换机需手动迁移 JSON 文件。
  No automatic cloud backup; migrate the JSON files manually between machines.

## 宣发材料 / Marketing materials

宣传截图使用隔离目录中的虚构事项数据，不包含真实用户数据。
Marketing screenshots use fictional items in isolated data directories and contain no real user data.
