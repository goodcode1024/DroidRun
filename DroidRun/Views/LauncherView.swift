import SwiftUI
import UniformTypeIdentifiers

struct LauncherView: View {
    @Bindable var viewModel: VMSessionViewModel
    @State private var showImporter = false

    private let columns = [GridItem(.adaptive(minimum: 72), spacing: 16)]

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.installedApps.isEmpty {
                    ContentUnavailableView(
                        "还没有应用",
                        systemImage: "square.grid.2x2",
                        description: Text("点右上角安装 APK")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.installedApps) { app in
                                NavigationLink {
                                    AppDetailView(viewModel: viewModel, app: app)
                                } label: {
                                    VStack(spacing: 6) {
                                        AppIcon(data: app.iconData)
                                        Text(app.label).font(.caption).lineLimit(1)
                                    }
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button { Task { await viewModel.launch(app) } } label: {
                                        Label("打开", systemImage: "play")
                                    }
                                    Button(role: .destructive) {
                                        Task { await viewModel.uninstall(app) }
                                    } label: {
                                        Label("卸载", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("应用")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showImporter = true } label: {
                        Label("安装 APK", systemImage: "plus")
                    }
                }
            }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.item]) { result in
                if case .success(let url) = result {
                    Task { await viewModel.installAPK(at: url) }
                }
            }
            .task { await viewModel.refreshInstalledApps() }
        }
    }
}
