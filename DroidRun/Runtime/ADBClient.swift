import Foundation
import Network

/// 极简 ADB 客户端（配 insecure ADB，无需 RSA 授权）。
///
/// 只覆盖与 Kernarium 交互所需的最小面：连接、发 host 命令、收回复。
/// ADB 线格式：每条消息 = 4 字节小端长度 + 命令(4) + 参数0(4) + 参数1(4) + payload。
/// Kernarium 的 Android 把 ADB 暴露在 127.0.0.1:58526 且关闭授权提示。
final class ADBClient: @unchecked Sendable {
    private let host: String
    private let port: UInt16
    private var connection: NWConnection?

    init(host: String, port: UInt16) {
        self.host = host
        self.port = port
    }

    func connect() async throws {
        let conn = NWConnection(
            to: .hostPort(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!),
            using: .tcp
        )
        connection = conn
        conn.start(queue: .global(qos: .userInitiated))
        try await waitUntilReady(conn)
        try await send(AdbMessage.connect)
    }

    /// 发送一个 host 服务请求并返回 payload。
    func request(_ service: String) async throws -> Data {
        try await send(AdbMessage.open(service))
        return try await receivePayload()
    }

    func close() {
        connection?.cancel()
        connection = nil
    }

    // MARK: - internals

    private func waitUntilReady(_ conn: NWConnection) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            var resumed = false
            conn.stateUpdateHandler = { state in
                guard !resumed else { return }
                switch state {
                case .ready:
                    resumed = true
                    cont.resume()
                case .failed(let error):
                    resumed = true
                    cont.resume(throwing: error)
                default:
                    break
                }
            }
        }
    }

    private func send(_ data: Data) async throws {
        guard let conn = connection else { throw ADBError.notConnected }
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            conn.send(content: data, completion: .contentProcessed { error in
                if let error { cont.resume(throwing: error) } else { cont.resume() }
            })
        }
    }

    private func receivePayload() async throws -> Data {
        guard let conn = connection else { throw ADBError.notConnected }
        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Data, Error>) in
            conn.receive(minimumIncompleteLength: 4, maximumLength: 4) { [conn] data, _, _, error in
                if let error { cont.resume(throwing: error); return }
                guard let data, data.count == 4 else { cont.resume(throwing: ADBError.badFraming); return }
                let length = data.withUnsafeBytes { $0.loadUnaligned(as: UInt32.self) }.littleEndian
                conn.receive(minimumIncompleteLength: Int(length), maximumLength: Int(length)) { payload, _, _, error in
                    if let error { cont.resume(throwing: error); return }
                    cont.resume(returning: payload ?? Data())
                }
            }
        }
    }
}

enum ADBError: LocalizedError {
    case notConnected
    case badFraming

    var errorDescription: String? {
        switch self {
        case .notConnected: return "ADB 未连接"
        case .badFraming: return "ADB 消息帧格式错误"
        }
    }
}

/// ADB 协议消息构造。
struct AdbMessage {
    /// 连接命令：CNXN, version=0x01000001, maxdata=4096, "host::\0"
    static let connect: Data = {
        var d = Data()
        d.append(AdbMessage.encode(command: "CNXN", arg0: 0x01000001, arg1: 4096))
        d.append(contentsOf: Array("host::\0".utf8))
        return d
    }()

    /// 打开一个 host 服务：OPEN, local-id, 0, "<service>\0"
    static func open(_ service: String) -> Data {
        var d = Data()
        d.append(encode(command: "OPEN", arg0: 1, arg1: 0))
        d.append(contentsOf: Array((service + "\0").utf8))
        return d
    }

    /// 组装消息头（不含长度前缀）。
    private static func encode(command: String, arg0: UInt32, arg1: UInt32) -> Data {
        var d = Data()
        d.append(contentsOf: Array(command.utf8.prefix(4)).padded(to: 4, with: 0))
        d.append(contentsOf: withUnsafeBytes(of: arg0.littleEndian) { Array($0) })
        d.append(contentsOf: withUnsafeBytes(of: arg1.littleEndian) { Array($0) })
        return d
    }
}

private extension Array where Element == UInt8 {
    func padded(to length: Int, with pad: UInt8) -> [UInt8] {
        count >= length ? Array(prefix(length)) : self + Array(repeating: pad, count: length - count)
    }
}
