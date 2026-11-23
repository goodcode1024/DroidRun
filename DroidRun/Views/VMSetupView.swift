import SwiftUI

struct VMSetupView: View {
    let viewModel: VMSessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = "Android 17"
    @State private var vCPU = 4
    @State private var memoryGB = 4.0
    @State private var resolution = VMConfiguration.Resolution.fhd
    @State private var storageGB = 8.0
    @State private var mode = PerformanceMode.smart

    var body: some View {
        NavigationStack {
            Form {
                Section("基本") {
                    TextField("名称", text: $name)
                }
                Section("性能") {
                    Stepper("CPU：\(vCPU) 核", value: $vCPU, in: 1...8)
                    VStack(alignment: .leading) {
                        Text("内存：\(Int(memoryGB)) GB")
                        Slider(value: $memoryGB, in: 2...6, step: 0.5)
                    }
                    Picker("分辨率", selection: $resolution) {
                        ForEach(VMConfiguration.Resolution.allCases) { r in
                            Text(r.rawValue).tag(r)
                        }
                    }
                    Picker("性能档位", selection: $mode) {
                        ForEach(PerformanceMode.allCases) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                }
                Section("存储") {
                    VStack(alignment: .leading) {
                        Text("存储：\(Int(storageGB)) GB")
                        Slider(value: $storageGB, in: 4...32, step: 1)
                    }
                }
                Section {
                    Button("创建并启动") {
                        let config = VMConfiguration(
                            name: name,
                            vCPUCount: vCPU,
                            memoryGB: memoryGB,
                            resolution: resolution,
                            storageGB: storageGB,
                            performanceMode: mode
                        )
                        Task { await viewModel.create(configuration: config) }
                        dismiss()
                    }
                } footer: {
                    Text("Android 系统镜像已内置在 App 中，即开即用，无需下载。")
                }
            }
            .navigationTitle("新建虚拟机")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}
