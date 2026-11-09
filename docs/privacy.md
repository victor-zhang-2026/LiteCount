# 数据与隐私 / Data and privacy

LiteCount 无账号、服务器、联网业务、遥测、分析和广告。应用不申请通知、联系人、日历、辅助功能等任何权限。

LiteCount has no accounts, server, networking, telemetry, analytics, or advertising. The app requests no permissions — no notifications, contacts, calendar, or accessibility.

## 存储位置 / Storage

- 事项数据与设置：`~/Library/Application Support/LiteCount/items.json`（未加密 JSON）+ 自动备份 `items.backup.json`。
  Items and settings: `~/Library/Application Support/LiteCount/items.json` (unencrypted JSON) with an automatic `items.backup.json`.
- 悬浮球位置等偏好：本机 `UserDefaults`。
  Ball position and preferences: local UserDefaults.
- 除上述本机文件外，LiteCount 不写入或读取任何其他位置，不访问摄像头、麦克风或屏幕内容。
  LiteCount touches nothing beyond those local files and never accesses camera, microphone, or screen content.

## 边界说明 / Limits

- 本地存储不等于加密或访问隔离：本机用户、备份工具与有文件访问权限的软件仍可读取文件，请自行保留备份。
  Local storage is not encryption or access control: other local users or tools with file access can read the files. Keep your own backups.
- 无自动云备份；换机需手动迁移 JSON 文件。
  No automatic cloud backup; migrate the JSON files manually between machines.

## 宣发材料 / Marketing materials

宣传截图使用隔离目录中的虚构事项数据，不包含真实用户数据。
Marketing screenshots use fictional items in isolated data directories and contain no real user data.
