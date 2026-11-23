import SwiftUI

struct HomeView: View {
    @State private var viewModel = VMSessionViewModel()
    @State private var showSetup = false

    var body: some View {
        NavigationStack {
            List {
                Section("虚拟机") {
                    if let config = viewModel.configuration {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(config.name).font(.headline)
                            Text("\(config.vCPUCount) 核 · \(Int(config.memoryGB)) GB 内存 · \(config.resolution.rawValue) · \(Int(config.storageGB)) GB 存储")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if viewModel.state == .running {
                            NavigationLink("进入 Android") {
                                SessionView(viewModel: viewModel)
                            }
                        }
                    } else {
                        Button("创建虚拟机") { showSetup = true }
                    }
                }
                Section {
                    Label("Android 系统镜像已内置，即开即用", systemImage: "internaldrive")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("DroidRun")
            .sheet(isPresented: $showSetup) {
                VMSetupView(viewModel: viewModel)
            }
        }
    }
}
