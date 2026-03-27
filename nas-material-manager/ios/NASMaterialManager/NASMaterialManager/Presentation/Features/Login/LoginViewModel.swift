import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var serverURL: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadSavedConfig()
    }

    private func loadSavedConfig() {
        if let data = UserDefaults.standard.data(forKey: "webdav_config"),
           let config = try? JSONDecoder().decode(WebDAVConfig.self, from: data) {
            serverURL = config.serverURL
            username = config.username
            password = config.password
        }
    }

    private func saveConfig() {
        let config = WebDAVConfig(
            serverURL: serverURL,
            username: username,
            password: password
        )
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: "webdav_config")
        }
    }

    func login() async {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: serverURL) else {
            errorMessage = "无效的服务器地址"
            isLoading = false
            return
        }

        let config = WebDAVConfiguration(
            serverURL: url,
            username: username,
            password: password
        )
        let client = WebDAVClient(config: config)

        do {
            let success = try await client.testConnection()
            if success {
                saveConfig()
                AppEnvironment.shared.webdavConfig = WebDAVConfig(
                    serverURL: serverURL,
                    username: username,
                    password: password
                )
                AppEnvironment.shared.isLoggedIn = true
            } else {
                errorMessage = "连接失败，请检查配置"
            }
        } catch {
            errorMessage = "连接错误: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
