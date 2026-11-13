# LiteCount 1.0.7 — MANIFEST

发布时间 / Released: 2026-11-13
构建 / Build: 1.0.7 (build 24) · ad-hoc 签名，未公证 / ad-hoc signed, not notarized

## 附件 / Attachments

| 文件 / File | 说明 / Purpose |
|---|---|
| `LiteCount-1.0.7-macOS-arm64.zip` | 应用包，含 LiteCount.app / App bundle containing LiteCount.app |
| `SHA256SUMS` | ZIP 的 SHA-256 校验和 / SHA-256 checksum for the ZIP |
| `MANIFEST.md` | 本清单 / This manifest |

## 校验 / Verification

```bash
shasum -a 256 -c SHA256SUMS
unzip -t LiteCount-1.0.7-macOS-arm64.zip
```

- ZIP SHA-256: `02f171206183a157097ac5ebd5a5fffa432788ffb1ee63769690f0a99c26446a`
- 解压后 App 版本：1.0.7 (build 24)；Bundle ID：`io.github.victor-zhang-2026.litecount`

## 变更摘要 / Summary

- 新增可选的单次到期前系统通知；仅在设置提醒时请求通知权限。
- Added an optional one-time macOS reminder per item; notification permission is requested only when setting a reminder.
