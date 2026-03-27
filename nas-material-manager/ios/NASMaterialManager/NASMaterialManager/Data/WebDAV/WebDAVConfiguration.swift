import Foundation

struct WebDAVConfiguration {
    let serverURL: URL
    let username: String
    let password: String

    var authHeader: String {
        let credentials = "\(username):\(password)".data(using: .utf8)!
        let base64 = credentials.base64EncodedString()
        return "Basic \(base64)"
    }
}
