import SwiftUI

/// 首次启动引导页。
struct OnboardingView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView {
            page(
                icon: "internaldrive",
                title: "内置镜像",
                text: "Android 17（LineageOS 24）系统镜像已打包进 App，即开即用，无需下载。"
            )
            page(
                icon: "shippingbox",
                title: "安装 APK",
                text: "从「文件」App 导入 .apk / .xapk，一键安装到虚拟机。"
            )
            page(
                icon: "bolt",
                title: "侧载 + JIT",
                text: "本 App 不上架，通过 AltStore / SideStore 侧载，并可用 StikDebug 启用 JIT 提速。"
            )
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .overlay(alignment: .bottom) {
            Button {
                hasOnboarded = true
                dismiss()
            } label: {
                Text("开始使用")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
    }

    private func page(icon: String, title: String, text: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            Text(title)
                .font(.title2.bold())
            Text(text)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(32)
    }
}
