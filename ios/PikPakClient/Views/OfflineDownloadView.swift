//
//  OfflineDownloadView.swift
//  PikPakClient
//
//  离线下载添加页面
//

import SwiftUI

struct OfflineDownloadView: View {
    let folderId: String
    @StateObject private var authManager = AuthManager.shared
    
    @Environment(\.dismiss) private var dismiss
    @State private var downloadURL = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var successMessage: String?
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("下载链接")) {
                    TextField("磁力链 / HTTP 链接", text: $downloadURL)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                }
                
                Section {
                    Button(action: addOfflineDownload) {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("开始下载")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(downloadURL.isEmpty || isLoading)
                }
                
                Section(footer: Text("支持磁力链（magnet:?xt=...）和 HTTP/HTTPS 直链")) {
                    EmptyView()
                }
            }
            .navigationTitle("离线下载")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .alert("错误", isPresented: $showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "未知错误")
            }
            .alert("成功", isPresented: $showSuccess) {
                Button("确定") {
                    dismiss()
                }
            } message: {
                Text(successMessage ?? "已添加离线下载任务")
            }
        }
    }
    
    private func addOfflineDownload() {
        isLoading = true
        
        Task {
            do {
                let result = try await APIService.shared.addOfflineDownload(
                    accessToken: authManager.accessToken,
                    url: downloadURL.trimmingCharacters(in: .whitespaces),
                    parentId: folderId
                )
                
                await MainActor.run {
                    successMessage = "已添加任务：\(result.name)"
                    showSuccess = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    OfflineDownloadView(folderId: "root")
}
