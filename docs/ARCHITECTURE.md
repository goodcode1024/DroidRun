# 架构

## 分层

```
┌─────────────────────────────────────────────┐
│  Views（SwiftUI）                            │
│  Home / Setup / Session / Launcher / Settings│
└──────────────────┬──────────────────────────┘
                   │ 仅依赖 VMSessionViewModel
┌──────────────────▼──────────────────────────┐
│  ViewModel（@Observable）                    │
│  会话状态机 + 应用状态 + 错误                 │
└──────────────────┬──────────────────────────┘
                   │ 仅依赖 RuntimeBridge 协议
┌──────────────────▼──────────────────────────┐
│  Runtime                                      │
│  RuntimeBridge（协议） → KernariumAdapter     │
│  ADBClient（127.0.0.1:58526, insecure ADB）  │
└──────────────────┬──────────────────────────┘
                   │ 集成缝（本仓库与 Kernarium 的边界）
┌──────────────────▼──────────────────────────┐
│  Kernarium runtime（外部，GPL-2.0）           │
│  UML 内核原生执行 + 用户态解释器/JIT +        │
│  Vulkan→Metal(KosmicKrisp)/Zink + UBD + slirp│
└─────────────────────────────────────────────┘
```

## 关键设计

- **内置镜像、即开即用**：LineageOS 镜像 + 内核 bundle 作为 App 资源打包进
  IPA（约 1GB+），`start(configuration:)` 只创建 guest（虚拟磁盘/CPU/内存/分辨率）。
- **抽象隔离**：上层只认 `RuntimeBridge`，替换底层 runtime 不影响 UI。
- **唯一集成缝**：`KernariumAdapter` 是对接 Kernarium 的唯一文件，遵守其
  「可执行内存唯一入口」等契约。

## 数据流

- 启动：`VMSetupView` 收集配置 → `VMSessionViewModel.create` → `bridge.start`。
- 装 APK：`LauncherView` 的 `fileImporter` 选文件 → `installAPK(at:)` → ADB `pm install`。
- 列应用：`listInstalledApps()` → ADB `pm list packages -3` + 图标。
- 状态：`statsStream()` → `PerformanceStats` → `SessionView` 浮层。
