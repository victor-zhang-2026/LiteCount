# LiteCount 1.0.2 — MANIFEST

发布时间 / Released: 2026-11-09
构建 / Build: 1.0.2 (build 4) · ad-hoc 签名，未公证 / ad-hoc signed, not notarized

## 附件 / Attachments

| 文件 / File | 说明 / Purpose |
|---|---|
| `LiteCount-1.0.2-macOS-arm64.zip` | 应用包，含 LiteCount.app / App bundle containing LiteCount.app |
| `SHA256SUMS` | ZIP 的 SHA-256 校验和 / SHA-256 checksum for the ZIP |
| `MANIFEST.md` | 本清单 / This manifest |

## 校验 / Verification

```bash
shasum -a 256 -c SHA256SUMS          # 在附件所在目录执行 / run in the downloads folder
unzip -t LiteCount-1.0.2-macOS-arm64.zip
```

- ZIP SHA-256: `d33a3bb9023c95257ff7fadb3468377fcd07185149494b4f00af57fed7a07f5a`
- 解压后 App 版本：1.0.2 (build 4)；Bundle ID：`io.github.victor-zhang-2026.litecount`

## 变更摘要 / Summary

- 修复 1.0.1 悬停滚动回归：未悬停时长名称不再遮挡倒计时列 / Fixed 1.0.1 hover-scroll regression.
- 其余与 1.0.1 相同 / Otherwise identical to 1.0.1.
