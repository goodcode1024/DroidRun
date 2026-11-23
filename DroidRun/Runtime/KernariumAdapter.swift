import Foundation

/// Kernarium runtime 适配器（集成缝）。
///
/// 这是把 DroidRun 接到真正 Android runtime 的唯一落点。Kernarium 的宿主
/// 代码在 `GuestHost/Sources`（runtime loader、显示/触控视图、着色器缓存）。
/// 适配思路：
///   1. 把 VMConfiguration 映射成 Kernarium 的 guest 启动参数（vCPU/内存/分辨率/存储）；
///   2. `start` 调用 GuestHost 的 runtime loader，加载「内置」在 App bundle
///      里的系统镜像与内核 bundle；
///   3. 显示层复用 GuestHost 的 Metal 触控视图（SessionView 里挂载）；
///   4. APK 安装 / 应用列表走 `ADBClient` 连接 127.0.0.1:58526（insecure ADB）。
///
/// 当前为文档化 stub：方法体保留清晰 TODO，保证 UI 层可独立编译运行；
/// 接入真实 runtime 时只需在本文件内实现协议方法，无需改动上层。
struct KernariumAdapter: RuntimeBridge {
    private let adb = ADBClient(host: "127.0.0.1", port: 58526)

    func start(configuration: VMConfiguration) async throws {
        // TODO(集成): 调用 GuestHost runtime loader，用 configuration 映射
        // 启动参数；系统镜像路径 = Bundle.main 内置资源（即开即用）。
        throw RuntimeError.notIntegrated("start")
    }

    func stop() async throws {
        // TODO(集成): 调用 runtime 的 guest 停止/销毁。
        throw RuntimeError.notIntegrated("stop")
    }

    func pause() async throws {
        // TODO(集成): 挂起 guest。
        throw RuntimeError.notIntegrated("pause")
    }

    func resume() async throws {
        // TODO(集成): 恢复 guest。
        throw RuntimeError.notIntegrated("resume")
    }

    func takeSnapshot(named name: String) async throws -> VMSnapshot {
        // TODO(集成): 保存 guest 快照。
        throw RuntimeError.notIntegrated("takeSnapshot")
    }

    func restoreSnapshot(_ snapshot: VMSnapshot) async throws {
        // TODO(集成): 恢复 guest 快照。
        throw RuntimeError.notIntegrated("restoreSnapshot")
    }

    func installAPK(at url: URL) async throws {
        // TODO(集成): adb push + `pm install`。
        throw RuntimeError.notIntegrated("installAPK")
    }

    func launchApp(packageName: String) async throws {
        // TODO(集成): `monkey -p <pkg> 1` 或 am start。
        throw RuntimeError.notIntegrated("launchApp")
    }

    func listInstalledApps() async throws -> [InstalledApp] {
        // TODO(集成): `pm list packages -3` + 图标提取。
        throw RuntimeError.notIntegrated("listInstalledApps")
    }

    func statsStream() -> AsyncStream<PerformanceStats> {
        // TODO(集成): 订阅 runtime 的统计通道，实时吐出 CPU/内存/VRAM/FPS。
        AsyncStream { _ in }
    }
}

enum RuntimeError: LocalizedError {
    case notIntegrated(String)

    var errorDescription: String? {
        switch self {
        case .notIntegrated(let fn):
            return "\(fn) 尚未接入 Kernarium runtime（见 KernariumAdapter.swift）"
        }
    }
}
