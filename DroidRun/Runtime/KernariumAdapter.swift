import Foundation

// =============================================================================
// KernariumAdapter — 真实集成参考（不是可编译的成品，是准确的接线图）
// -----------------------------------------------------------------------------
// 已查明的真相（截至 andarium-1.1 / Kernarium main）：
//
// 1. 真正运行 Android 的是 Kernarium 的 C++ 运行时（darwin/ 目录），它被
//    打包成预编译框架（`.build/kernarium-xcframeworks`），通过一段 C 接口
//    `kernarium_runtime_api` 暴露给 Swift。该接口定义在
//    `Kernarium/Runtime/KernariumRuntime.h`，由 `GuestHost/Sources/
//    KernariumRuntimeLoader.h/.mm` 在 Swift 侧包装成 `KernariumRuntimeLoader`。
//
// 2. 生产级 Swift 调用层是 Andarium 的：
//      - `Andarium/Andarium/Shared/RuntimeDriver.swift`（@MainActor 协议）
//      - `Andarium/Andarium/Live/LiveRuntime.swift`（真机实现）
//      - `Andarium/AndariumCore/`（Swift Package：ADB 客户端 + Android 应用管理）
//    因此「把 DroidRun 跑起来」的正确姿势是复用它们，而不是在本文件里重写。
//
// 3. 结论：DroidRun 若想真正运行 APK，唯一稳妥路线是 fork/rebrand Andarium
//    （见 goodcode1024/Kernarium 仓库的 docs/BUILD.zh-CN.md），把它的 UI 换成
//    自己的品牌。本文件的 RuntimeBridge 协议是"UI 层对运行时能力的最小抽象"，
//    用于对齐两个世界的调用面。
// =============================================================================

// -----------------------------------------------------------------------------
// 真实 C API 面（供接线时对照）——摘自 Kernarium/Runtime/KernariumRuntime.h
// -----------------------------------------------------------------------------
// typedef int (*kernarium_runtime_run_function)(
//     void* context, const kernarium_runtime_boot* boot);          // 启动并阻塞到关机
// typedef void (*kernarium_runtime_request_stop_function)(void);   // 请求停止
// typedef int  (*kernarium_runtime_sync_function)(kernarium_runtime_settle*);      // 同步磁盘
// typedef int  (*kernarium_runtime_quiesce_function)(kernarium_runtime_settle*);   // 暂停
// typedef int  (*kernarium_runtime_quiesce_resident_function)(kernarium_runtime_settle*);
// typedef void (*kernarium_runtime_resume_function)(void);         // 恢复
// typedef void (*kernarium_runtime_send_touch_function)(...);      // 多点触控
// typedef void (*kernarium_runtime_cancel_touch_function)(uint32_t slot);
// typedef void (*kernarium_runtime_send_key_function)(...);        // 按键
// typedef void (*kernarium_runtime_set_console_output_callback)(...);
// typedef int  (*kernarium_runtime_send_console_input_function)(...);
// typedef int  (*kernarium_runtime_set_frame_sink_function)(...);  // 显示帧回传
// typedef int  (*kernarium_runtime_prepare_jit_function)(...);     // JIT
// typedef int  (*kernarium_runtime_plan_gpu_budget_function)(...);
//
// kernarium_runtime_boot 关键字段（Android guest）：
//   android_data_gib（数据盘大小）、分辨率/密度、vCPU、内存预算、
//   android_host_features（方向/磁力计/120Hz）、android_camera_mode、
//   android_serial_number / android_ethernet_mac、android_root（Magisk）等。
//
// 启动入口（loader）：
//   KernariumRuntimeLoader 的 kernarium_runtime_loader_run(...)
//
// 显示：GuestHost/Sources/GuestDisplay.swift 的 Metal 视图（Metal 4，A14+）。
// 触控：GuestHost/Sources/GuestInput.swift 把 UIKit 触摸映射到 guest 触摸屏。
// ADB ：Andarium/AndariumCore/Sources/AndariumCore/Adb/*（vsock 上的 adbd，
//       而非本仓库 ADBClient 假设的 TCP 127.0.0.1:58526）。
// =============================================================================

/// 把 DroidRun 的 UI 层抽象，映射到 Andarium 真实 RuntimeDriver 的对照表。
/// 生产实现见 Andarium/Live/LiveRuntime.swift（不要在本仓库重写运行时）。
struct KernariumAdapter: RuntimeBridge {
    // 说明：真实集成时，这里应持有一个 `RuntimeDriver`（Andarium 的协议实现）
    // 或直接持有 `KernariumRuntimeLoader` 封装的 `kernarium_runtime_api`。

    func start(configuration: VMConfiguration) async throws {
        // 对应：RuntimeDriver.begin(guest:mode:kind:) + kernarium_runtime_loader_run
        //   - 把 VMConfiguration 映射为 kernarium_runtime_boot（vCPU/内存/分辨率/数据盘）
        //   - 系统镜像 = App bundle 内置（stage-system-image.py 产物），即开即用
        throw RuntimeError.notIntegrated("start → kernarium_runtime_loader_run")
    }

    func stop() async throws {
        // 对应：kernarium_runtime_request_stop()
        throw RuntimeError.notIntegrated("stop → kernarium_runtime_request_stop")
    }

    func pause() async throws {
        // 对应：kernarium_runtime_quiesce()（写回 + 暂停）
        throw RuntimeError.notIntegrated("pause → kernarium_runtime_quiesce")
    }

    func resume() async throws {
        // 对应：kernarium_runtime_resume()
        throw RuntimeError.notIntegrated("resume → kernarium_runtime_resume")
    }

    func takeSnapshot(named name: String) async throws -> VMSnapshot {
        // 对应：Andarium 的 SnapshotDriver（磁盘快照，非运行时 API）
        throw RuntimeError.notIntegrated("takeSnapshot")
    }

    func listSnapshots() async throws -> [VMSnapshot] {
        throw RuntimeError.notIntegrated("listSnapshots")
    }

    func restoreSnapshot(_ snapshot: VMSnapshot) async throws {
        throw RuntimeError.notIntegrated("restoreSnapshot")
    }

    func deleteSnapshot(_ snapshot: VMSnapshot) async throws {
        throw RuntimeError.notIntegrated("deleteSnapshot")
    }

    func installAPK(at url: URL) async throws {
        // 对应：RuntimeDriver.installApk(at:bypassLowTargetSdkBlock:update:)
        //   → AndariumCore 的 ADB 客户端（vsock adbd）：push + `pm install`
        throw RuntimeError.notIntegrated("installAPK → AndariumCore ADB")
    }

    func launchApp(packageName: String) async throws {
        // 对应：AndariumCore 的 AndroidApps / `am start` 或 `monkey`
        throw RuntimeError.notIntegrated("launchApp")
    }

    func uninstallApp(packageName: String) async throws {
        // 对应：`pm uninstall <pkg>`
        throw RuntimeError.notIntegrated("uninstallApp")
    }

    func listInstalledApps() async throws -> [InstalledApp] {
        // 对应：AndariumCore 的 AndroidAppStore / `pm list packages`
        throw RuntimeError.notIntegrated("listInstalledApps")
    }

    func setRotationLock(_ locked: Bool) async throws {
        // 对应：MotionOrientation / 方向 host feature
        throw RuntimeError.notIntegrated("setRotationLock")
    }

    func statsStream() -> AsyncStream<PerformanceStats> {
        // 对应：Andarium 的 Stats/StatsDrawn（runtime 统计通道）
        AsyncStream { _ in }
    }
}

enum RuntimeError: LocalizedError {
    case notIntegrated(String)

    var errorDescription: String? {
        switch self {
        case .notIntegrated(let fn):
            return "\(fn) 未接入——生产实现请复用 Andarium 的 RuntimeDriver/LiveRuntime（见 goodcode1024/Kernarium 仓库）"
        }
    }
}
