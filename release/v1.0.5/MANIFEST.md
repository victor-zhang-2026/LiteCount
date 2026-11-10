# LiteCount 1.0.5 — MANIFEST

发布时间 / Released: 2026-11-10
构建 / Build: 1.0.5 (build 15) · ad-hoc 签名，未公证 / ad-hoc signed, not notarized

## 附件 / Attachments

| 文件 / File | 说明 / Purpose |
|---|---|
| `LiteCount-1.0.5-macOS-arm64.zip` | 应用包，含 LiteCount.app / App bundle containing LiteCount.app |
| `SHA256SUMS` | ZIP 的 SHA-256 校验和 / SHA-256 checksum for the ZIP |
| `MANIFEST.md` | 本清单 / This manifest |

## 校验 / Verification

```bash
shasum -a 256 -c SHA256SUMS
unzip -t LiteCount-1.0.5-macOS-arm64.zip
```

- ZIP SHA-256: `000455331dc5ecdc07c24f70e87bb6c082e69d7583789e6c7f8811221aed3a85`
- 解压后 App 版本：1.0.5 (build 15)；Bundle ID：`io.github.victor-zhang-2026.litecount`

## 变更摘要 / Summary

- 列表与编辑界面等尺寸，图标颜色选择入口移至名称框，目标时间下方直接显示倒计时，语言切换保留草稿。
- Equal-sized list and editor, inline icon/color picker, live countdown below target time, and draft preservation across language changes.
