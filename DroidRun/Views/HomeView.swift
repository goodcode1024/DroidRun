import SwiftUI

struct HomeView: View {
    @State private var viewModel = VMSessionViewModel()
    @State private var showSetup = false
    @State private var showOnboarding: Bool

    init() {
        _showOnboarding = State(initialValue: !UserDefaults.standard.bool(forKey: "hasOnboarded"))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let config = viewModel.configuration {
                        vmCard(config)
                    } else {
                        emptyState
                    }
                    infoBanner
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("DroidRun")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.configuration != nil {
                        Button { showSetup = true } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
            }
            .sheet(isPresented: $showSetup) {
                VMSetupView(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView()
            }
        }
    }

    // MARK: - 内容

    private var emptyState: some View {
        VStack(spacing: 20) {
            ContentUnavailableView {
                Label("还没有虚拟机", systemImage: "rectangle.stack.badge.play")
            } description: {
                Text("创建一台 Android 虚拟机，安装并运行 APK")
            } actions: {
                Button("创建虚拟机") { showSetup = true }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
        }
        .padding(.vertical, 32)
    }

    private func vmCard(_ config: VMConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(config.name).font(.title3.bold())
                Spacer()
                SessionStateBadge(state: viewModel.state)
            }

            Text(configSummary(config))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            HStack {
                if viewModel.state == .running {
                    NavigationLink {
                        SessionView(viewModel: viewModel)
                    } label: {
                        Label("进入 Android", systemImage: "play.rectangle.on.rectangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        Task { await viewModel.start() }
                    } label: {
                        Label("启动", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isBusy)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private var infoBanner: some View {
        Label("Android 系统镜像已内置，即开即用", systemImage: "internaldrive")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }

    private func configSummary(_ c: VMConfiguration) -> String {
        "\(c.vCPUCount) 核 · \(Int(c.memoryGB)) GB 内存 · \(c.resolution.rawValue) · \(Int(c.storageGB)) GB 存储 · \(c.performanceMode.rawValue)"
    }
}
