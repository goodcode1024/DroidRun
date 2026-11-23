import SwiftUI

/// 应用图标（有数据用图片，否则占位）。
struct AppIcon: View {
    let data: Data?
    var size: CGFloat = 56

    var body: some View {
        Group {
            if let data, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFit()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.22)
                        .fill(.quaternary)
                    Image(systemName: "app")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
    }
}

/// 会话状态徽标。
struct SessionStateBadge: View {
    let state: VMSessionViewModel.SessionState

    var body: some View {
        Text(state.label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(state.color.opacity(0.18), in: Capsule())
            .foregroundStyle(state.color)
    }
}

extension VMSessionViewModel.SessionState {
    var label: String {
        switch self {
        case .idle: return "未启动"
        case .booting: return "启动中"
        case .running: return "运行中"
        case .paused: return "已暂停"
        case .stopping: return "停止中"
        }
    }

    var color: Color {
        switch self {
        case .idle: return .secondary
        case .booting: return .orange
        case .running: return .green
        case .paused: return .yellow
        case .stopping: return .orange
        }
    }
}

/// 性能浮层小胶囊。
struct StatPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2.monospacedDigit())
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(.ultraThinMaterial, in: Capsule())
            .foregroundStyle(.white)
    }
}
