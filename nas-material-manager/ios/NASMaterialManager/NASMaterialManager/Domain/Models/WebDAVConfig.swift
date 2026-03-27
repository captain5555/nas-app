import Foundation

struct WebDAVConfig: Codable {
    let serverURL: String
    let username: String
    let password: String

    enum CodingKeys: String, CodingKey {
        case serverURL = "server_url"
        case username
        case password
    }
}
