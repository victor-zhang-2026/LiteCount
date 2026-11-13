# LiteCount 1.0.8 — MANIFEST

发布时间 / Released: 2026-11-13
构建 / Build: 1.0.8 (build 26) · ad-hoc 签名，未公证 / ad-hoc signed, not notarized

## 附件 / Attachments

| 文件 / File | 说明 / Purpose |
|---|---|
| `LiteCount-1.0.8-macOS-arm64.zip` | 应用包，含 LiteCount.app / App bundle containing LiteCount.app |
| `SHA256SUMS` | ZIP 的 SHA-256 校验和 / SHA-256 checksum for the ZIP |
| `MANIFEST.md` | 本清单 / This manifest |

## 校验 / Verification

```bash
shasum -a 256 -c SHA256SUMS
unzip -t LiteCount-1.0.8-macOS-arm64.zip
```

- ZIP SHA-256: `7803a53e9d6dd0e25e8ef35334e282dbad50ba8ef22dfe8d69666e77d3085ab7`
- 解压后 App 版本：1.0.8 (build 26)；Bundle ID：`io.github.victor-zhang-2026.litecount`

## 变更摘要 / Summary

- 浮窗头部与「关于」窗口使用 LiteCount 自有品牌图标。
- The floating panel header and About window use LiteCount's own icon artwork.
