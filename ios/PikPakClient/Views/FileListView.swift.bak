//
//  FileListView.swift
//  PikPakClient
//
//  文件列表主界面
//

import SwiftUI

struct FileListView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var files: [FileItem] = []
    @State private var currentFolderId = "root"
    @State private var currentFolderName = "全部文件"
    @State private var folderStack: [(id: String, name: String)] = [("root", "全部文件")]
    @State private var isLoading = false
    @State private var showUploadMenu = false
    @State private var showOfflineDownload = false
    @State private var showTasks = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(files) { file in
                    FileRowView(file: file)
                        .onTapGesture {
                            if file.isFolder {
                                navigateToFolder(file)
                            }
                        }
                }
            }
            .navigationTitle(currentFolderName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // 左上角：菜单/返回
                ToolbarItem(placement: .navigationBarLeading) {
                    if folderStack.count > 1 {
                        Button("返回") {
                            navigateBack()
                        }
                    } else {
                        Button {
                            authManager.logout()
                        } label: {
                            Image(systemName: "person.circle")
                                .font(.title)
                        }
                    }
                }
                
                // 右上角：加号按钮
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showUploadMenu = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
                
                // 任务列表按钮
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showTasks = true
                    } label: {
                        Image(systemName: "arrow.down.circle")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showUploadMenu) {
                UploadMenuView(
                    currentFolderId: currentFolderId,
                    onOfflineDownload: {
                        showOfflineDownload = true
                    }
                )
            }
            .sheet(isPresented: $showOfflineDownload) {
                OfflineDownloadView(folderId: currentFolderId)
            }
            .sheet(isPresented: $showTasks) {
                TasksView()
            }
            .alert("错误", isPresented: $showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "未知错误")
            }
            .refreshable {
                await loadFiles()
            }
            .onAppear {
                if files.isEmpty {
                    Task {
                        await loadFiles()
                    }
                }
            }
        }
    }
    
    // 加载文件列表
    private func loadFiles() async {
        isLoading = true
        
        do {
            let result = try await APIService.shared.listFiles(
                accessToken: authManager.accessToken,
                parentId: currentFolderId
            )
            
            await MainActor.run {
                self.files = result.files
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
                isLoading = false
            }
        }
    }
    
    // 进入文件夹
    private func navigateToFolder(_ folder: FileItem) {
        folderStack.append((folder.id, folder.name))
        currentFolderId = folder.id
        currentFolderName = folder.name
        
        Task {
            await loadFiles()
        }
    }
    
    // 返回上一级
    private func navigateBack() {
        guard folderStack.count > 1 else { return }
        folderStack.removeLast()
        let current = folderStack.last!
        currentFolderId = current.id
        currentFolderName = current.name
        
        Task {
            await loadFiles()
        }
    }
}
