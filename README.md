# DroidRun

在 iPhone/iPad 上**本地运行 Android 17（LineageOS 24）并安装运行 APK** 的 App 层设计 + 集成参考。

- **内置镜像、即开即用**：Android 系统镜像随 App 打包（约 1GB+），首次打开无需下载。
- **不装传统虚拟机**：底层走 User-mode Linux（内核原生执行 + 用户态解释器/JIT），不依赖 QEMU/Hypervisor。
- **不上架、侧载 + JIT**：面向 AltStore / SideStore 侧载，可启用 JIT。

## 重要结论（先读这个）

经过对 Kernarium 源码的完整核查，必须如实说明：

> **能完整运行 APK 的 App 已经存在，它就是 [Andarium](https://github.com/imxieyi/Kernarium)（本仓库上游）。**
> 它把 LineageOS 24 整机 + 内核 + Metal 显示 + ADB + APK 安装全部实现好了，
> 并且在 release 里发布了**可直接侧载的成品 IPA**（`Andarium-1.1-16.ipa`，1.16GB）。

运行 Android 的核心是 Kernarium 的 **C++ 运行时**（9000+ commit，含 UML 内核宿主、
arm64/x86 解释器+JIT、Vulkan→Metal 翻译层），Swift 侧通过一段 C 接口
`kernarium_runtime_api`（`Kernarium/Runtime/KernariumRuntime.h`）驱动。**这段运行时
无法从零重写，也不是一个"适配器文件"能替代的**——生产级 Swift 调用层是 Andarium 的
`Live/LiveRuntime.swift` + `AndariumCore`（ADB 客户端）。

因此本仓库的定位是：

| 内容 | 说明 |
|------|------|
| `Views/` + `ViewModels/` + `Models/` | 一套**完整的 SwiftUI 界面设计**（首页/新建/会话/启动器/快照/设置），可直接作为 rebrand 的 UI 参考 |
| `Runtime/RuntimeBridge.swift` | 对运行时能力的**最小抽象协议**（UI 层只依赖它） |
| `Runtime/KernariumAdapter.swift` | **真实集成接线图**：把每个方法映射到真实 C API / Andarium RuntimeDriver |
| `Runtime/ADBClient.swift` | ADB 协议参考实现（注意：Andarium 实际走 vsock adbd，非 TCP） |

## 最快拿到"能跑 APK 的 App"的三条路

| 路径 | 耗时 | 需要 Mac/Xcode 27 |
|------|------|:---:|
| ① 直接侧载上游预编译 IPA | 5 分钟 | ❌ |
| ② 在 AltStore/SideStore 加侧载源 | 3 分钟 | ❌ |
| ③ 从源码构建 / rebrand 成自己的 App | 数小时 | ✅ |

**路径①**：下载 `https://github.com/imxieyi/Kernarium/releases/download/andarium-1.1/Andarium-1.1-16.ipa`，AltStore/SideStore 侧载（iOS 26+、A14+）。

**路径②**：侧载源 `https://raw.githubusercontent.com/goodcode1024/Kernarium/main/sideload/source.json`

**路径③（真正"做自己的 App"）**：见 [goodcode1024/Kernarium](https://github.com/goodcode1024/Kernarium) 仓库的 `docs/BUILD.zh-CN.md` —— fork/rebrand Andarium（改 bundle id、名字、图标），按官方序列构建：

```sh
cmake --preset kernarium-ios-device-android && cmake --build --preset kernarium-ios-device-android
Kernarium/scripts/package-ios-frameworks.sh --runtimes android
Andarium/scripts/stage-system-image.py
xcodebuild -project Andarium/Andarium.xcodeproj -scheme Andarium -destination 'generic/platform=iOS' build
```

> 本仓库（DroidRun）的 UI 与接线图，可用来指导你 rebrand 后要改哪些界面；但**真正运行 APK 的能力来自 Andarium 的运行时**，请勿期待仅靠本仓库的 Swift 代码跑起 Android。

## 仓库结构

```
DroidRun/
├── DroidRun/
│   ├── DroidRunApp.swift
│   ├── Models/               # VMConfiguration / InstalledApp / Snapshot / Stats
│   ├── ViewModels/           # VMSessionViewModel（会话状态机）
│   ├── Runtime/              # RuntimeBridge 协议 + KernariumAdapter(接线图) + ADBClient
│   └── Views/                # 首页 / 引导 / 新建 / 会话 / 启动器 / 快照 / 设置 / 侧键
├── project.yml               # XcodeGen 工程定义
├── docs/ARCHITECTURE.md
└── .github/workflows/build.yml
```

## 本仓库构建（仅验证 UI 层编译）

```sh
brew install xcodegen
xcodegen generate
open DroidRun.xcodeproj
```

UI 层可在 iOS 模拟器独立编译运行（runtime 为接线图占位，不真正跑 Android）。

## 许可证

GPL-2.0-or-later（与 Kernarium 保持一致，避免 copyleft 冲突）。
