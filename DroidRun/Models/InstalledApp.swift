import Foundation

/// 已安装的 Android 应用（来自 `pm list packages` + 图标）。
struct InstalledApp: Identifiable, Hashable {
    let id = UUID()
    let packageName: String
    let label: String
    var iconData: Data?
}
