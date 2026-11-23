import Foundation

/// App 层与 Kernarium runtime 之间的桥接协议。
///
/// 「内置镜像、即开即用」体现在这里：Android 系统镜像（LineageOS）作为
/// App 的 bundled resource 打包进 IPA，`start(configuration:)` 只负责创建
/// guest（虚拟磁盘、CPU/内存/分辨率），不涉及下载镜像。
///
/// 唯一生产实现是 `KernariumAdapter`（见同目录），它把调用转发给
/// Kernarium 的 GuestHost runtime loader。协议存在的意义是：UI 与模型只
/// 依赖这个抽象，替换/升级底层 runtime 不影响上层。
protocol RuntimeBridge: Sendable {
    /// 启动虚拟机（镜像已内置，无需下载）。
    func start(configuration: VMConfiguration) async throws
    /// 停止虚拟机。
    func stop() async throws
    /// 暂停（切后台时调用）。
    func pause() async throws
    /// 恢复。
    func resume() async throws
    /// 创建快照。
    func takeSnapshot(named name: String) async throws -> VMSnapshot
    /// 恢复快照。
    func restoreSnapshot(_ snapshot: VMSnapshot) async throws
    /// 安装 APK。
    func installAPK(at url: URL) async throws
    /// 启动某个已安装应用。
    func launchApp(packageName: String) async throws
    /// 列出已安装应用。
    func listInstalledApps() async throws -> [InstalledApp]
    /// 实时性能指标流。
    func statsStream() -> AsyncStream<PerformanceStats>
}
