import Foundation

/// 性能档位：映射到 Android 的电源/调度策略与帧率上限。
enum PerformanceMode: String, CaseIterable, Identifiable, Codable {
    case powerSaver = "省电"
    case smart = "均衡"
    case standard = "标准"
    case performance = "性能"

    var id: String { rawValue }

    var maxFPS: Int {
        switch self {
        case .powerSaver: return 30
        case .smart: return 60
        case .standard: return 90
        case .performance: return 120
        }
    }
}

/// 虚拟机配置。用户创建的是 guest（虚拟磁盘），
/// 而 Android 系统镜像本身「内置」在 App 里，即开即用。
struct VMConfiguration: Identifiable, Codable {
    var id = UUID()
    var name: String = "Android 17"
    var vCPUCount: Int = 4
    var memoryGB: Double = 4.0
    var resolution: Resolution = .fhd
    var storageGB: Double = 8.0
    var performanceMode: PerformanceMode = .smart

    enum Resolution: String, CaseIterable, Identifiable, Codable {
        case hd = "720p"
        case fhd = "1080p"
        case qhd = "1440p"

        var id: String { rawValue }

        var pixels: (width: Int, height: Int) {
            switch self {
            case .hd: return (720, 1280)
            case .fhd: return (1080, 1920)
            case .qhd: return (1440, 2560)
            }
        }
    }
}
