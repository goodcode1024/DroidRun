import SwiftUI

/// 侧键浮层：电源 / 音量 +/- / 返回 / 主页。
struct SideKeysView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                key("power")
                key("minus")
                key("plus")
                key("arrow.uturn.backward")
                key("house")
            }
            .padding(8)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.trailing, 12)
            .padding(.bottom, 44)
        }
    }

    private func key(_ systemImage: String) -> some View {
        Button {
            // TODO(集成): 通过 GuestHost 输入桥把键事件转发给 Android。
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 40, height: 40)
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }
}
