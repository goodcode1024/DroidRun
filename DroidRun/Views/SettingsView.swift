import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: VMSessionViewModel
    @AppStorage("allow.camera") private var camera = false
    @AppStorage("allow.mic") private var mic = false
    @AppStorage("allow.location") private var location = false
    @AppStorage("allow.haptics") private var haptics = true

    var body: some View {
        NavigationStack {
            Form {
                Section("权限") {
                    Toggle("相机", isOn: $camera)
                    Toggle("麦克风", isOn: $mic)
                    Toggle("定位", isOn: $location)
                    Toggle("触感反馈", isOn: $haptics)
                }
                if let c = viewModel.configuration {
                    Section("虚拟机") {
                        LabeledContent("名称", value: c.name)
                        LabeledContent("CPU", value: "\(c.vCPUCount) 核")
                        LabeledContent("内存", value: "\(Int(c.memoryGB)) GB")
                        LabeledContent("分辨率", value: c.resolution.rawValue)
                        LabeledContent("存储", value: "\(Int(c.storageGB)) GB")
                        LabeledContent("性能档位", value: c.performanceMode.rawValue)
                    }
                }
                Section("开发者") {
                    LabeledContent("ADB 端口", value: "127.0.0.1:58526")
                    LabeledContent("JIT", value: "侧载 + StikDebug")
                }
                Section("关于") {
                    LabeledContent("系统镜像", value: "内置（即开即用）")
                    LabeledContent("Android", value: "17（LineageOS 24）")
                    LabeledContent("版本", value: "0.1.0")
                }
            }
            .navigationTitle("设置")
        }
    }
}
