//
//  Models.swift
//  PikPakClient
//
//  数据模型定义
//

import Foundation

// MARK: - 用户模型
struct User: Codable {
    let sub: String
    let name: String
    let email: String
}

// MARK: - 登录响应
struct LoginResponse: Codable {
    let success: Bool
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case success
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case user
    }
}

// MARK: - 文件项
struct FileItem: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let kind: String  // folder / file
    let mimeType: String
    let size: Int64
    let createdAt: String
    let modifiedAt: String
    let parentId: String
    let thumbnail: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, kind, size
        case mimeType = "mime_type"
        case createdAt = "created_at"
        case modifiedAt = "modified_at"
        case parentId = "parent_id"
        case thumbnail
    }
    
    var isFolder: Bool {
        kind == "folder"
    }
    
    var formattedSize: String {
        if isFolder { return "--" }
        let byteCount = ByteCountFormatter()
        byteCount.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        byteCount.countStyle = .file
        return byteCount.string(fromByteCount: size)
    }
}

// MARK: - 文件列表响应
struct FileListResponse: Codable {
    let success: Bool
    let files: [FileItem]
    let nextCursor: String?
    
    enum CodingKeys: String, CodingKey {
        case success, files
        case nextCursor = "next_cursor"
    }
}

// MARK: - 任务项
struct TaskItem: Codable, Identifiable {
    let id: String
    let name: String
    let status: String  // PENDING / RUNNING / COMPLETED / ERROR
    let progress: Int
    let type: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, status, progress, type
        case createdAt = "created_at"
    }
    
    var statusText: String {
        switch status {
        case "PENDING": return "等待中"
        case "RUNNING": return "下载中"
        case "COMPLETED": return "已完成"
        case "ERROR": return "失败"
        default: return status
        }
    }
}

// MARK: - 任务列表响应
struct TaskListResponse: Codable {
    let success: Bool
    let tasks: [TaskItem]
}

// MARK: - 离线下载响应
struct OfflineDownloadResponse: Codable {
    let success: Bool
    let taskId: String
    let fileId: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case taskId = "task_id"
        case fileId = "file_id"
        case name
    }
}
