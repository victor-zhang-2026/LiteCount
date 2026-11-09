import Foundation

enum ProductIdentity {
    static let englishName = Bundle.main.object(forInfoDictionaryKey: "LiteCountEnglishName") as? String ?? "LiteCount"
    static let dataDirectoryName = Bundle.main.object(forInfoDictionaryKey: "LiteCountDataDirectory") as? String ?? "LiteCount"
    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }
    static var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "dev"
    }
}
