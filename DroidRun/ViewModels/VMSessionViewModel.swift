import Foundation
import Observation

/// 会话状态机 + 应用状态容器。UI 层唯一依赖的模型。
@Observable
final class VMSessionViewModel {
    enum SessionState: Equatable {
        case idle
        case booting
        case running
        case paused
        case stopping
    }

    var configuration: VMConfiguration?
    var state: SessionState = .idle
    var stats = PerformanceStats()
    var installedApps: [InstalledApp] = []
    var snapshots: [VMSnapshot] = []
    var errorMessage: String?

    private let bridge: RuntimeBridge

    init(bridge: RuntimeBridge = KernariumAdapter()) {
        self.bridge = bridge
    }

    @MainActor
    func create(configuration: VMConfiguration) async {
        self.configuration = configuration
        state = .booting
        errorMessage = nil
        do {
            try await bridge.start(configuration: configuration)
            state = .running
        } catch {
            state = .idle
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func stop() async {
        state = .stopping
        do { try await bridge.stop() } catch { errorMessage = error.localizedDescription }
        state = .idle
    }

    @MainActor
    func pause() async {
        do {
            try await bridge.pause()
            state = .paused
        } catch { errorMessage = error.localizedDescription }
    }

    @MainActor
    func resume() async {
        do {
            try await bridge.resume()
            state = .running
        } catch { errorMessage = error.localizedDescription }
    }

    @MainActor
    func takeSnapshot(named name: String) async {
        do {
            let snap = try await bridge.takeSnapshot(named: name)
            snapshots.append(snap)
        } catch { errorMessage = error.localizedDescription }
    }

    @MainActor
    func installAPK(at url: URL) async {
        do { try await bridge.installAPK(at: url) } catch { errorMessage = error.localizedDescription }
        await refreshInstalledApps()
    }

    @MainActor
    func launch(_ app: InstalledApp) async {
        do { try await bridge.launchApp(packageName: app.packageName) }
        catch { errorMessage = error.localizedDescription }
    }

    @MainActor
    func refreshInstalledApps() async {
        do { installedApps = try await bridge.listInstalledApps() }
        catch { errorMessage = error.localizedDescription }
    }
}
