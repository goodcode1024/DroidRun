import SwiftUI

struct SessionView: View {
    @Bindable var viewModel: VMSessionViewModel
    @State private var showLauncher = false
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            // TODO(集成): 在此挂载 Kernarium GuestHost 的 Metal 触控视图，
            // 显示 Android 画面并接收多点触控。
            GuestDisplayPlaceholder()
            SideKeysView()
            statsOverlay
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showLauncher = true } label: { Label("应用", systemImage: "square.grid.2x2") }
                    Button { showSettings = true } label: { Label("设置", systemImage: "gearshape") }
                    Button { Task { await viewModel.pause() } } label: { Label("暂停", systemImage: "pause") }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showLauncher) { LauncherView(viewModel: viewModel) }
        .sheet(isPresented: $showSettings) { SettingsView(viewModel: viewModel) }
    }

    private var statsOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Text(String(format: "CPU %.0f%%", viewModel.stats.cpuPercent))
                Text(String(format: "%.0f fps", viewModel.stats.fps))
                Text(String(format: "%.1fG/%.1fG", viewModel.stats.memoryUsedGB, viewModel.stats.memoryTotalGB))
            }
            .font(.caption2.monospacedDigit())
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.bottom, 12)
        }
    }
}

private struct GuestDisplayPlaceholder: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "rectangle.on.rectangle")
                .font(.system(size: 40))
            Text("Android 显示区域")
                .font(.headline)
            Text("此处将由 Kernarium runtime 的 Metal 视图接管")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.white.opacity(0.6))
    }
}
