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
                Section("关于") {
                    LabeledContent("系统镜像", value: "内置（即开即用）")
                    LabeledContent("Android", value: "17（LineageOS 24）")
                }
            }
            .navigationTitle("设置")
        }
    }
}
