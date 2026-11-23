import Foundation

/// 实时性能指标，用于浮层展示。
struct PerformanceStats: Equatable {
    var cpuPercent: Double = 0
    var memoryUsedGB: Double = 0
    var memoryTotalGB: Double = 4
    var vramUsedGB: Double = 0
    var vramTotalGB: Double = 0
    var fps: Double = 0
}
