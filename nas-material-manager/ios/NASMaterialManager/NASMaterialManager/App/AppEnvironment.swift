import Foundation

class AppEnvironment: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var webdavConfig: WebDAVConfig?

    static let shared = AppEnvironment()

    private init() {}
}
