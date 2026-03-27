import Foundation

class WebDAVClient {
    private let config: WebDAVConfiguration
    private let session: URLSession

    init(config: WebDAVConfiguration) {
        self.config = config
        let sessionConfig = URLSessionConfiguration.default
        self.session = URLSession(configuration: sessionConfig)
    }

    func testConnection() async throws -> Bool {
        let request = makeRequest(path: "", method: "PROPFIND")
        let (_, response) = try await session.data(for: request)
        return (response as? HTTPURLResponse)?.statusCode == 207
    }

    func listDirectory(path: String) async throws -> [WebDAVItem] {
        var request = makeRequest(path: path, method: "PROPFIND")
        request.setValue("1", forHTTPHeaderField: "Depth")
        let (data, _) = try await session.data(for: request)
        return parsePROPFINDResponse(data)
    }

    func downloadFile(path: String) async throws -> Data {
        let request = makeRequest(path: path, method: "GET")
        let (data, _) = try await session.data(for: request)
        return data
    }

    func uploadFile(path: String, data: Data, contentType: String = "application/octet-stream") async throws {
        var request = makeRequest(path: path, method: "PUT")
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        _ = try await session.upload(for: request, from: data)
    }

    func deleteFile(path: String) async throws {
        let request = makeRequest(path: path, method: "DELETE")
        _ = try await session.data(for: request)
    }

    func createFolder(path: String) async throws {
        let request = makeRequest(path: path, method: "MKCOL")
        _ = try await session.data(for: request)
    }

    func downloadIndexFile(path: String) async throws -> IndexFile {
        let data = try await downloadFile(path: path)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(IndexFile.self, from: data)
    }

    func uploadIndexFile(path: String, index: IndexFile) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(index)
        try await uploadFile(path: path, data: data, contentType: "application/json")
    }

    private func makeRequest(path: String, method: String) -> URLRequest {
        let url = config.serverURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(config.authHeader, forHTTPHeaderField: "Authorization")
        return request
    }

    private func parsePROPFINDResponse(_ data: Data) -> [WebDAVItem] {
        // 简化实现，实际需要解析 XML
        // 返回示例
        return []
    }
}

struct WebDAVItem {
    let path: String
    let name: String
    let isDirectory: Bool
    let size: Int64?
    let modifiedAt: Date?
}
