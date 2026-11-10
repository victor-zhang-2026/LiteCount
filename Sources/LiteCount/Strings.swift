import Foundation

enum L10n {
    private static let languageKey = "appLanguage"

    static var isChinese: Bool {
        if let stored = UserDefaults.standard.string(forKey: languageKey) {
            return stored == "zh"
        }
        return Locale.current.language.languageCode?.identifier == "zh"
    }

    static func text(_ zh: String, _ en: String) -> String { isChinese ? zh : en }

    static func toggleLanguage() {
        UserDefaults.standard.set(isChinese ? "en" : "zh", forKey: languageKey)
    }

    static var appName: String { ProductIdentity.englishName }
    static var about: String { text("关于", "About") }
    static var aboutTitle: String { text("关于 LiteCount", "About LiteCount") }
    static var aboutDescription: String { text("桌面轻量倒计时", "Lightweight Desktop Countdown") }
    static var switchToLight: String { text("切换到浅色模式", "Switch to Light Mode") }
    static var switchToDark: String { text("切换到深色模式", "Switch to Dark Mode") }
    static var closePanel: String { text("收起列表", "Close Panel") }
    static var quit: String { text("退出 LiteCount", "Quit LiteCount") }
    static var quitTitle: String { text("退出 LiteCount？", "Quit LiteCount?") }
    static var quitMessage: String { text("确定要退出吗？", "Are you sure you want to quit?") }
    static var quitConfirm: String { text("退出", "Quit") }
    static var cancel: String { text("取消", "Cancel") }
    static var save: String { text("保存", "Save") }
    static var add: String { text("新增", "New") }
    static var edit: String { text("编辑", "Edit") }
    static var delete: String { text("删除", "Delete") }
    static var deleteTitle: String { text("删除这条倒计时事项？", "Delete this countdown item?") }
    static var deleteMessage: String { text("删除后无法恢复。", "This action cannot be undone.") }
    static var pinPanel: String { text("固定浮窗", "Pin Panel") }
    static var unpinPanel: String { text("取消固定", "Unpin Panel") }
    static var namePlaceholder: String { text("事项名称…", "Item name…") }
    static var chooseIcon: String { text("选择图标", "Choose Icon") }
    static var chooseColor: String { text("选择颜色", "Choose Color") }
    static var pastHint: String { text("目标时间需晚于现在", "Target must be in the future") }
    static var chooseTime: String { text("选择时间", "Choose Time") }
    static var done: String { text("完成", "Done") }
    static var hourColumn: String { text("时", "Hour") }
    static var minuteColumn: String { text("分", "Min") }
    static var emptyTitle: String { text("还没有倒计时事项", "No countdown items yet") }
    static var emptyHint: String { text("添加第一个重要时刻吧", "Add your first important moment") }
    static var noUpcoming: String { text("暂无进行中的事项", "No upcoming items") }
    static var noExpired: String { text("暂无已过期事项", "No expired items") }
    static var expired: String { text("已过期", "Expired") }
    static var back: String { text("返回", "Back") }
    static var dayUnit: String { text("天", "d") }
    static var switchToEnglish: String { text("Switch to English", "切换到中文") }
}
