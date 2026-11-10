# LiteCount 1.0.4 — MANIFEST

发布时间 / Released: 2026-11-10
构建 / Build: 1.0.4 (build 9) · ad-hoc 签名，未公证 / ad-hoc signed, not notarized

## 附件 / Attachments

| 文件 / File | 说明 / Purpose |
|---|---|
| `LiteCount-1.0.4-macOS-arm64.zip` | 应用包，含 LiteCount.app / App bundle containing LiteCount.app |
| `SHA256SUMS` | ZIP 的 SHA-256 校验和 / SHA-256 checksum for the ZIP |
| `MANIFEST.md` | 本清单 / This manifest |

## 校验 / Verification

```bash
shasum -a 256 -c SHA256SUMS
unzip -t LiteCount-1.0.4-macOS-arm64.zip
```

- ZIP SHA-256: `2c4ad3a62a5910ac463c8ddbe066cac960d1484728cba1382cc8eb8eaad30ea3`
- 解压后 App 版本：1.0.4 (build 9)；Bundle ID：`io.github.victor-zhang-2026.litecount`

## 变更摘要 / Summary

- 自动归档已过期事项，角标仅计进行中事项，并修复面板遮挡悬浮球。
- Automatic Expired view, upcoming-only badge, and corrected panel placement.
