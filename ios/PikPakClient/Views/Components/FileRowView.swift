//
//  FileRowView.swift
//  PikPakClient
//
//  文件列表行组件
//

import SwiftUI

struct FileRowView: View {
    let file: FileItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 文件图标
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.1))
                .cornerRadius(8)
            
            // 文件名和信息
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.body)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(file.formattedSize)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("·")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatDate(file.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 文件夹箭头
            if file.isFolder {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var iconName: String {
        if file.isFolder {
            return "folder.fill"
        }
        
        switch file.mimeType {
        case "video/mp4", "video/quicktime":
            return "play.rectangle.fill"
        case "image/jpeg", "image/png", "image/gif":
            return "photo.fill"
        case "application/pdf":
            return "doc.richtext.fill"
        case "application/zip", "application/x-rar-compressed":
            return "archivebox.fill"
        default:
            return "doc.fill"
        }
    }
    
    private var iconColor: Color {
        if file.isFolder {
            return .blue
        }
        
        switch file.mimeType {
        case "video/mp4", "video/quicktime":
            return .purple
        case "image/jpeg", "image/png", "image/gif":
            return .pink
        case "application/pdf":
            return .red
        case "application/zip", "application/x-rar-compressed":
            return .orange
        default:
            return .gray
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MM-dd HH:mm"
        return displayFormatter.string(from: date)
    }
}

#Preview {
    FileRowView(file: FileItem(
        id: "123",
        name: "测试文件夹",
        kind: "folder",
        mimeType: "folder",
        size: 0,
        createdAt: "2026-01-01T00:00:00Z",
        modifiedAt: "2026-01-01T00:00:00Z",
        parentId: "root",
        thumbnail: ""
    ))
}
