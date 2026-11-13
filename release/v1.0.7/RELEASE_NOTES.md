# LiteCount 1.0.7 发布说明 / Release notes

日期 / Date: 2026-11-13
构建 / Build: 1.0.7 (build 24)
平台 / Platform: macOS 14+ · Apple Silicon (arm64)
签名 / Signature: ad-hoc（未公证 / not notarized）

## 新增 / New

- 在创建或编辑事项时，可填写到期前的天、时、分；留空或全零即不提醒。
- 到达设定时间时，macOS 为该事项发送一次通知。修改事项会更新通知，删除事项或清空提醒会取消通知。
- 首次设置提醒时，请在 macOS 弹窗中允许 LiteCount 发送通知。若此前拒绝，可前往「系统设置 → 通知 → LiteCount」开启「允许通知」。

- Enter days, hours, and minutes before an item's target time. Empty or all-zero fields mean no reminder.
- macOS schedules one notification for the item. Editing reschedules it; deleting the item or clearing the reminder cancels it.
- When prompted the first time you set a reminder, allow LiteCount to send notifications. If previously denied, enable Allow Notifications in System Settings → Notifications → LiteCount.

[Apple 通知设置说明 / Apple's notification settings guide](https://support.apple.com/guide/mac-help/change-notifications-settings-mchl205da693/mac)

## 附件 / Attachments

- `LiteCount-1.0.7-macOS-arm64.zip` — 应用包 / app bundle
- `SHA256SUMS` — ZIP 校验和 / checksum
- `MANIFEST.md` — 清单与校验说明 / manifest
