import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "folder.fill")
                .font(.system(size: 60))
                .foregroundColor(Theme.primaryColor)

            Text("NAS 素材管理")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                TextField("WebDAV 地址 (http://...)", text: $viewModel.serverURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)

                TextField("用户名", text: $viewModel.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)

                SecureField("密码", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal, 40)

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: {
                Task {
                    await viewModel.login()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("登录")
                        .fontWeight(.semibold)
                }
            }
            .frame(minWidth: 200)
            .padding()
            .background(Theme.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(viewModel.isLoading)

            Spacer()
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
