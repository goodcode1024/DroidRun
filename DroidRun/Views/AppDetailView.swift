import SwiftUI

/// 应用详情：查看、打开、卸载。
struct AppDetailView: View {
    @Bindable var viewModel: VMSessionViewModel
    let app: InstalledApp

    var body: some View {
        Form {
            Section {
                HStack(spacing: 16) {
                    AppIcon(data: app.iconData, size: 64)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(app.label).font(.title3.bold())
                        Text(app.packageName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            Section {
                Button {
                    Task { await viewModel.launch(app) }
                } label: {
                    Label("打开", systemImage: "play.fill")
                }
                Button(role: .destructive) {
                    Task { await viewModel.uninstall(app) }
                } label: {
                    Label("卸载", systemImage: "trash")
                }
            }
        }
        .navigationTitle("应用详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
