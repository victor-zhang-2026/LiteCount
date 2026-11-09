# LiteCount 1.0.0 发布说明 / Release notes

日期 / Date: 2026-11-09
构建 / Build: 1.0.0 (build 2)
平台 / Platform: macOS 14+ · Apple Silicon (arm64)
签名 / Signature: ad-hoc（未公证 / not notarized）

## 亮点 / Highlights

- 桌面悬浮球：蓝色沙漏 + 事项总数角标，悬停展开、延迟收起、拖动定位、显示器相对定位。
  Floating ball with hourglass mark and total-count badge; hover to expand, persistent per-display position.
- 倒计时事项：名称 + 目标时间（分钟精度）+ 图标颜色；创建即倒计时、由近至远排序、重启恢复。
  Countdown items with minute-precision targets, icons and colors; auto-start, auto-sort, restart recovery.
- 实时剩余天时分秒；到期显示「已到期」，无负数。
  Live d/h/m/s counters; expired items show "Expired", never negative.
- 合并式日期时间选择浮层；本地化日期格式；浅色/深色与中/英文界面。
  Combined date-time picker; localized formats; light/dark and zh/en UI.
- 数据完全本地：JSON + 自动备份，无账户、无网络、无提醒。
  Local-only JSON with automatic backup; no accounts, no networking, no notifications.

## 附件 / Attachments

- `LiteCount-1.0.0-macOS-arm64.zip` — 应用包 / app bundle
- `SHA256SUMS` — 附件校验和 / checksums
- `MANIFEST.md` — 附件清单与校验说明 / manifest

安装与数据说明见 [docs/install-and-data.md](../docs/install-and-data.md)。
