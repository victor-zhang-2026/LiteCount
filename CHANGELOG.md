# Changelog

## 1.0.2 — 2026-11-09

- 修复 1.0.1 悬停滚动引入的缺陷：未悬停时长名称全文溢出并遮挡倒计时列；现在文本严格裁剪在名称区域内，悬停时往返滚动显示全部内容。
- Fixed a 1.0.1 regression where unhovered long names overlapped the countdown column; text is now clipped to its area and scrolls on hover.

## 1.0.1 — 2026-11-09

- 列表行事项名称过长时，鼠标悬停后自动往返滚动显示完整内容，不再以省略号截断。
- Row names that overflow now ping-pong scroll on hover, replacing the ellipsis truncation.

## 1.0.0 — 2026-11-09

- 桌面悬浮球：蓝色主题、固定沙漏图标、事项总数角标；悬停展开列表、延迟收起、自由拖动并记住位置。
- 倒计时事项：名称 + 目标时间（分钟精度）+ 图标与颜色；创建即倒计时，按目标时间由近至远排序，重启自动恢复。
- 实时显示剩余天、时、分、秒；到期事项停止倒计时并显示「已到期」，不出现负数。
- 合并式日期时间选择浮层：日历与时/分同屏选择，本地化格式跟随应用语言（中/英）。
- 上百个系统图标与十种精选配色；界面支持浅色/深色模式与中英文切换。
- 数据完全本地存储（JSON + 备份）；无提醒、无统计、无账户、无网络功能。

English highlights:

- Floating ball trigger with live countdown list, total-count badge, and persistent position.
- Items with name, minute-precision target time, icon and color; auto-start, near-to-far sorting, restart recovery.
- Combined calendar-and-time picker; locale-aware formats; light/dark and zh/en UI.
- Local-only JSON storage with backup; no notifications, statistics, accounts, or networking.
