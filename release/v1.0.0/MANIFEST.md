# LiteCount 1.0.0 — MANIFEST

发布时间 / Released: 2026-11-09
构建 / Build: 1.0.0 (build 2) · ad-hoc 签名，未公证 / ad-hoc signed, not notarized

## 附件 / Attachments

| 文件 / File | 说明 / Purpose |
|---|---|
| `LiteCount-1.0.0-macOS-arm64.zip` | 应用包，含 LiteCount.app / App bundle containing LiteCount.app |
| `SHA256SUMS` | ZIP 的 SHA-256 校验和 / SHA-256 checksum for the ZIP |
| `MANIFEST.md` | 本清单 / This manifest |

## 校验 / Verification

```bash
shasum -a 256 -c SHA256SUMS          # 在附件所在目录执行 / run in the downloads folder
unzip -t LiteCount-1.0.0-macOS-arm64.zip
```

- ZIP SHA-256: `7654032c1597f3d0c3a35b8782118c27931f4e85fb5a1a9878077c4479841ab1`
- 解压后 App 版本：1.0.0 (build 2)；可执行文件 `LiteCount.app/Contents/MacOS/LiteCount`
- Bundle ID：`io.github.victor-zhang-2026.litecount`

## 内容边界 / Scope

- ZIP 仅含 `LiteCount.app`；不含项目记忆、真实用户数据或本地素材。
- 源代码以仓库 tag `v1.0.0` 为准；发布物与已验收构建逐字节一致。
- The ZIP contains only the app bundle. Source of truth for code is tag `v1.0.0`.
