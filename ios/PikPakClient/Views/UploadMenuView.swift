//
//  UploadMenuView.swift
//  PikPakClient
//
//  上传菜单弹窗
//

import SwiftUI
import PhotosUI

struct UploadMenuView: View {
    let currentFolderId: String
    let onOfflineDownload: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isUploading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("添加到 PikPak")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                VStack(spacing: 12) {
                    // 相册上传
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 10, matching: .images) {
                        UploadOptionRow(
                            icon: "photo.on.rectangle",
                            title: "从相册上传",
                            subtitle: "选择照片或视频上传",
                            color: .blue
                        )
                    }
                    
                    // 文件上传
                    Button {
                        // TODO: 实现文件选择器
                        dismiss()
                    } label: {
                        UploadOptionRow(
                            icon: "folder",
                            title: "从文件上传",
                            subtitle: "选择本地文件上传",
                            color: .green
                        )
                    }
                    
                    // 离线下载
                    Button {
                        dismiss()
                        onOfflineDownload()
                    } label: {
                        UploadOptionRow(
                            icon: "link.badge.plus",
                            title: "离线下载",
                            subtitle: "磁力链 / HTTP 链接下载",
                            color: .orange
                        )
                    }
                    
                    // 新建文件夹
                    Button {
                        // TODO: 实现新建文件夹
                        dismiss()
                    } label: {
                        UploadOptionRow(
                            icon: "folder.badge.plus",
                            title: "新建文件夹",
                            subtitle: "在当前目录创建新文件夹",
                            color: .purple
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedItems) { newItems in
                if !newItems.isEmpty {
                    uploadPhotos(items: newItems)
                }
            }
        }
    }
    
    private func uploadPhotos(items: [PhotosPickerItem]) {
        isUploading = true
        // TODO: 实现图片上传到 PikPak
        // Vercel Serverless 上传文件有限制，建议使用客户端直传
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isUploading = false
            dismiss()
        }
    }
}

// MARK: - 上传选项行
struct UploadOptionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    UploadMenuView(currentFolderId: "root", onOfflineDownload: {})
}
