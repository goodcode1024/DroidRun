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
    var rotationLocked = false
    var errorMessage: String?
    var isBusy = false

    private let bridge: RuntimeBridge

    init(bridge: RuntimeBridge = KernariumAdapter()) {
        self.bridge = bridge
    }

    // MARK: - 生命周期

    @MainActor
    func create(configuration: VMConfiguration) async {
        self.configuration = configuration
        state = .booting
        isBusy = true
        errorMessage = nil
        do {
            try await bridge.start(configuration: configuration)
            state = .running
        } catch {
            state = .idle
            errorMessage = error.localizedDescription
        }
        isBusy = false
    }

    @MainActor
    func start() async {
        guard let config = configuration else { return }
        await create(configuration: config)
    }

    @MainActor
    func stop() async {
        state = .stopping
        isBusy = true
        do { try await bridge.stop() } catch { errorMessage = error.localizedDescription }
        state = .idle
        isBusy = false
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

    // MARK: - 快照

    @MainActor
    func refreshSnapshots() async {
        do { snapshots = try await bridge.listSnapshots() }
        catch { errorMessage = error.localizedDescription }
    }

    @MainActor
    func takeSnapshot(named name: String) async {
        do {
            let snap = try await bridge.takeSnapshot(named: name)
            snapshots.append(snap)
        } catch { errorMessage = error.localizedDescription }
    }

    @MainActor
    func restoreSnapshot(_ snapshot: VMSnapshot) async {
        isBusy = true
        do { try await bridge.restoreSnapshot(snapshot) } catch { errorMessage = error.localizedDescription }
        isBusy = false
    }

    @MainActor
    func deleteSnapshot(_ snapshot: VMSnapshot) async {
        do {
            try await bridge.deleteSnapshot(snapshot)
            snapshots.removeAll { $0.id == snapshot.id }
        } catch { errorMessage = error.localizedDescription }
    }

    // MARK: - 应用

    @MainActor
    func installAPK(at url: URL) async {
        isBusy = true
        do { try await bridge.installAPK(at: url) } catch { errorMessage = error.localizedDescription }
        isBusy = false
        await refreshInstalledApps()
    }

    @MainActor
    func launch(_ app: InstalledApp) async {
        do { try await bridge.launchApp(packageName: app.packageName) }
        catch { errorMessage = error.localizedDescription }
    }

    @MainActor
    func uninstall(_ app: InstalledApp) async {
        do {
            try await bridge.uninstallApp(packageName: app.packageName)
            installedApps.removeAll { $0.id == app.id }
        } catch { errorMessage = error.localizedDescription }
    }

    @MainActor
    func refreshInstalledApps() async {
        do { installedApps = try await bridge.listInstalledApps() }
        catch { errorMessage = error.localizedDescription }
    }

    // MARK: - 其他

    @MainActor
    func toggleRotationLock() async {
        rotationLocked.toggle()
        do { try await bridge.setRotationLock(rotationLocked) }
        catch { errorMessage = error.localizedDescription }
    }
}
