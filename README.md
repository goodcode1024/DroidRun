# DroidRun

在 iPhone/iPad 上**本地运行 Android 17（LineageOS 24）并安装运行 APK** 的 App 层。

- **内置镜像、即开即用**：Android 系统镜像随 App 打包（约 1GB+），首次打开无需下载。
- **不装传统虚拟机**：底层走 User-mode Linux（内核原生执行 + 用户态解释器/JIT），不依赖 QEMU/Hypervisor。
- **不上架、侧载 + JIT**：本仓库面向 AltStore / SideStore 侧载，可启用 JIT。

> ⚠️ **诚实声明**：本仓库是**应用层（SwiftUI）+ 集成缝**。真正运行 Android 的
> 引擎是 [Kernarium](https://github.com/imxieyi/Kernarium)（GPL-2.0），本项目不重造它，
> 而是通过 `Runtime/KernariumAdapter.swift` 接入。该适配器当前为**文档化 stub**，
> 需要在 Mac + Xcode 27 上按 `AGENTS.md` 完成与 GuestHost 的接线后才能运行 APK。

## 仓库结构

```
DroidRun/
├── DroidRun/                 # SwiftUI App（可独立编译的 UI/模型层）
│   ├── DroidRunApp.swift
│   ├── Models/               # VMConfiguration / InstalledApp / Snapshot / Stats
│   ├── ViewModels/           # VMSessionViewModel（会话状态机）
│   ├── Runtime/              # RuntimeBridge 协议 + KernariumAdapter(集成缝) + ADBClient
│   └── Views/                # 首页 / 新建 / 会话 / 启动器 / 设置 / 侧键
├── project.yml               # XcodeGen 工程定义
├── docs/ARCHITECTURE.md
└── .github/workflows/build.yml
```

## 快速开始

```sh
brew install xcodegen
xcodegen generate
open DroidRun.xcodeproj
```

UI 层可在 iOS 模拟器独立运行（runtime 为 stub）。接入真机 runtime 见
`AGENTS.md` 与 `Runtime/KernariumAdapter.swift`。

## 集成路线（关键）

1. **内置镜像**：在 Kernarium 构建流程里，把预编译的 LineageOS 镜像 +
   内核 bundle 放进 App bundle（上游用 `Andarium/scripts/stage-system-image.py`）。
2. **接 runtime**：把 `KernariumAdapter` 的每个方法转发到 Kernarium 的
   GuestHost runtime loader。
3. **显示**：`SessionView` 里挂载 GuestHost 的 Metal 触控视图。
4. **ADB**：`ADBClient` 连 `127.0.0.1:58526`（insecure ADB）装 APK / 列应用。

## 许可证

GPL-2.0-or-later（与 Kernarium 保持一致，避免 copyleft 冲突）。
