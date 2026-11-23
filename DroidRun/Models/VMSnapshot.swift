import Foundation

/// 虚拟机快照。
struct VMSnapshot: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let createdAt: Date
}
