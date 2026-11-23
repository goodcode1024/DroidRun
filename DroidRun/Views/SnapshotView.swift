import SwiftUI

/// 快照管理：列表、新建、恢复、删除。
struct SnapshotView: View {
    @Bindable var viewModel: VMSessionViewModel
    @State private var showCreate = false
    @State private var snapshotName = "快照"

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.snapshots.isEmpty {
                    ContentUnavailableView(
                        "还没有快照",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("保存当前虚拟机状态，随时恢复")
                    )
                } else {
                    List {
                        ForEach(viewModel.snapshots) { snap in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(snap.name).font(.headline)
                                    Text(snap.createdAt, format: .dateTime)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button("恢复") {
                                    Task { await viewModel.restoreSnapshot(snap) }
                                }
                                .buttonStyle(.bordered)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task { await viewModel.deleteSnapshot(snap) }
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("快照")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showCreate = true } label: {
                        Label("新建", systemImage: "plus")
                    }
                }
            }
            .task { await viewModel.refreshSnapshots() }
            .alert("新建快照", isPresented: $showCreate) {
                TextField("名称", text: $snapshotName)
                Button("保存") {
                    Task { await viewModel.takeSnapshot(named: snapshotName) }
                    snapshotName = "快照"
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("为当前虚拟机状态创建一个快照")
            }
        }
    }
}
