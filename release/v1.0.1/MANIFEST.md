# LiteCount 1.0.1 — MANIFEST

发布时间 / Released: 2026-11-09
构建 / Build: 1.0.1 (build 3) · ad-hoc 签名，未公证 / ad-hoc signed, not notarized

## 附件 / Attachments

| 文件 / File | 说明 / Purpose |
|---|---|
| `LiteCount-1.0.1-macOS-arm64.zip` | 应用包，含 LiteCount.app / App bundle containing LiteCount.app |
| `SHA256SUMS` | ZIP 的 SHA-256 校验和 / SHA-256 checksum for the ZIP |
| `MANIFEST.md` | 本清单 / This manifest |

## 校验 / Verification

```bash
shasum -a 256 -c SHA256SUMS          # 在附件所在目录执行 / run in the downloads folder
unzip -t LiteCount-1.0.1-macOS-arm64.zip
```

- ZIP SHA-256: `11676a3a9434da57e3228e2d31750b2eefdef785544a1636039d06652c16189c`
- 解压后 App 版本：1.0.1 (build 3)；Bundle ID：`io.github.victor-zhang-2026.litecount`

## 变更摘要 / Summary

- 事项名称过长时鼠标悬停自动往返滚动，替代省略号截断 / Long item names ping-pong scroll on hover.
- 其余与 1.0.0 相同 / Otherwise identical to 1.0.0.
