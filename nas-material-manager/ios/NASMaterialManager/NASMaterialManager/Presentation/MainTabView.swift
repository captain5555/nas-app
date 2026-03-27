import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            BrowserView()
                .tabItem {
                    Label("浏览", systemImage: "folder")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("NAS 配置") {
                    NavigationLink("服务器设置") {
                        ServerSettingsView()
                    }
                }
                Section("数据") {
                    Button("清除缓存") {
                        // 清除缓存
                    }
                }
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

struct ServerSettingsView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section {
                TextField("WebDAV 地址 (http://...)", text: $viewModel.serverURL)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                TextField("用户名", text: $viewModel.username)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                SecureField("密码", text: $viewModel.password)
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }

            Section {
                Button(action: {
                    Task {
                        await viewModel.login()
                        if AppEnvironment.shared.isLoggedIn {
                            dismiss()
                        }
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("测试并保存")
                    }
                }
            }
        }
        .navigationTitle("服务器设置")
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
