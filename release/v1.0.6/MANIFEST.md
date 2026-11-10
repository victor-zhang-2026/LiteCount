# LiteCount 1.0.6 — MANIFEST

发布时间 / Released: 2026-11-10
构建 / Build: 1.0.6 (build 17) · ad-hoc 签名，未公证 / ad-hoc signed, not notarized

## 附件 / Attachments

| 文件 / File | 说明 / Purpose |
|---|---|
| `LiteCount-1.0.6-macOS-arm64.zip` | 应用包，含 LiteCount.app / App bundle containing LiteCount.app |
| `SHA256SUMS` | ZIP 的 SHA-256 校验和 / SHA-256 checksum for the ZIP |
| `MANIFEST.md` | 本清单 / This manifest |

## 校验 / Verification

```bash
shasum -a 256 -c SHA256SUMS
unzip -t LiteCount-1.0.6-macOS-arm64.zip
```

- ZIP SHA-256: `2bb5604803ec3fd2cbd5dae8dba3b40d6d8d24834b1ce969a5406faa4711a330`
- 解压后 App 版本：1.0.6 (build 17)；Bundle ID：`io.github.victor-zhang-2026.litecount`

## 变更摘要 / Summary

- 日期时间选择框与名称框对齐，英文时间改用 24 小时制。
- Aligned date and name fields, with 24-hour English time display.
