//
//  LoginView.swift
//  PikPakClient
//
//  登录页面
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                // Logo 区域
                VStack(spacing: 12) {
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    Text("PikPak")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                Spacer()
                    .frame(height: 40)
                
                // 输入区域
                VStack(spacing: 16) {
                    TextField("邮箱", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                    
                    SecureField("密码", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal, 32)
                
                // 错误提示
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // 登录按钮
                Button(action: login) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("登录")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal, 32)
                .disabled(isLoading)
                
                Spacer()
            }
        }
    }
    
    private func login() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await APIService.shared.login(username: username, password: password)
                authManager.saveLoginResponse(response)
            } catch {
                errorMessage = "登录失败：\(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
}
