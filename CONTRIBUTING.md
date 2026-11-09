# Contributing to LiteCount

感谢关注 LiteCount！当前为个人维护的轻量桌面工具系列项目。

Thanks for your interest in LiteCount. It is a personally maintained member of a small desktop-tool series.

## 反馈 / Feedback

- 使用问题与功能建议请提 [Issue](https://github.com/victor-zhang-2026/LiteCount/issues)，中文或英文均可。
- 报告缺陷时请附：macOS 版本、机型、复现步骤与期望行为。
- Open an Issue in either language; include macOS version, machine model, steps, and expected behavior.

## 范围 / Scope

LiteCount 刻意保持轻量：无提醒、无统计、无分类、无账户与同步。与该边界冲突的提案可能不会采纳。
LiteCount is intentionally minimal: no notifications, statistics, categories, accounts, or sync. Proposals beyond that scope may be declined.

## 开发 / Development

- Swift 6 + SwiftUI/AppKit，零第三方依赖；构建说明见 README。
- 每个发布包必须经 `scripts/build-app.sh` 打包与 ad-hoc 签名；版本号只增不减，发布物不可变。
- 提交 PR 前请确保 `swift build` 通过，并描述动机与手动验证情况。
