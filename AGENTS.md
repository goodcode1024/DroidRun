# AGENTS.md

面向编码智能体的仓库指引。

## 项目是什么

DroidRun 是「在 iOS 上本地运行 Android/APK」的 App 层（SwiftUI + 集成缝），
底层引擎是 Kernarium（GPL-2.0，User-mode Linux + 解释器/JIT + Vulkan→Metal）。

## 构建

```sh
brew install xcodegen
xcodegen generate
xcodebuild -project DroidRun.xcodeproj -scheme DroidRun \
  -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO
```

## 代码约定

- Swift 5.9+，iOS 17+，`@Observable`（`import Observation`）。
- UI 与模型**只依赖** `RuntimeBridge` 协议，禁止直接引用 Kernarium 符号。
- 所有对底层 runtime 的调用都收敛到 `Runtime/KernariumAdapter.swift`。
- `ADBClient` 只覆盖最小 ADB 面（CNXN/OPEN + 长度前缀帧），不引入重型依赖。
- 修改工程用 XcodeGen（改 `project.yml`），不要手改 `.xcodeproj`。

## 集成 Kernarium 的落点（按顺序）

1. `Runtime/KernariumAdapter.swift` —— 把协议方法接到 GuestHost runtime loader。
2. `Views/SessionView.swift` —— 挂载 GuestHost 的 Metal 触控视图。
3. `Views/SideKeysView.swift` —— 键事件转发。
4. `Runtime/ADBClient.swift` —— 装 APK / 列应用 / 启动应用。

## 不要做

- 不要从零重写 Linux 内核 / CPU 解释器 / 图形栈（复用 Kernarium）。
- 不要在 `KernariumAdapter` 之外 `mmap` 可执行内存（Kernarium 有唯一入口约束）。
- 不要引入会与 GPL-2.0 冲突的闭源依赖。
