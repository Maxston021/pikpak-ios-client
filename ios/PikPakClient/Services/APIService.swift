//
//  APIService.swift
//  PikPakClient
//
//  API 请求服务层
//

import Foundation

class APIService: ObservableObject {
    static let shared = APIService()
    
    // 后端 API 地址 - 用老的、被信任的部署
    let baseURL = "https://douyuan.de5.net"
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - 登录
    func login(username: String, password: String) async throws -> LoginResponse {
        let url = URL(string: "\(baseURL)/api/pikpak/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["username": username, "password": password]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let bodyStr = String(data: data, encoding: .utf8) ?? "unknown"
            throw APIError.httpError(httpResponse.statusCode, bodyStr)
        }
        
        do {
            return try JSONDecoder.pikPakDecoder.decode(LoginResponse.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
    
    // MARK: - 获取文件列表
    func listFiles(accessToken: String, parentId: String = "root", cursor: String? = nil) async throws -> FileListResponse {
        var urlComponents = URLComponents(string: "\(baseURL)/api/files")!
        var queryItems = [
            URLQueryItem(name: "access_token", value: accessToken),
            URLQueryItem(name: "parent_id", value: parentId),
            URLQueryItem(name: "limit", value: "50")
        ]
        if let cursor = cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }
        urlComponents.queryItems = queryItems
        
        let (data, response) = try await session.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder.pikPakDecoder.decode(FileListResponse.self, from: data)
    }
    
    // MARK: - 创建文件夹
    func createFolder(accessToken: String, name: String, parentId: String = "root") async throws -> [String: Any] {
        let url = URL(string: "\(baseURL)/api/folder?access_token=\(accessToken)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["name": name, "parent_id": parentId]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }
    
    // MARK: - 添加离线下载
    func addOfflineDownload(accessToken: String, url: String, parentId: String = "root") async throws -> OfflineDownloadResponse {
        let apiURL = URL(string: "\(baseURL)/api/offline-download?access_token=\(accessToken)")!
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["url": url, "parent_id": parentId]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder.pikPakDecoder.decode(OfflineDownloadResponse.self, from: data)
    }
    
    // MARK: - 获取任务列表
    func listTasks(accessToken: String) async throws -> TaskListResponse {
        let url = URL(string: "\(baseURL)/api/tasks?access_token=\(accessToken)&limit=20")!
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder.pikPakDecoder.decode(TaskListResponse.self, from: data)
    }
}

// MARK: - 错误类型
enum APIError: LocalizedError {
    case invalidResponse
    case httpError(Int, String)
    case decodingError
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "无效的服务器响应"
        case .httpError(let code, let body):
            return "HTTP \(code): \(body)"
        case .decodingError:
            return "数据解析错误"
        case .unauthorized:
            return "未授权，请重新登录"
        }
    }
}

// MARK: - JSONDecoder 扩展
extension JSONDecoder {
    static let pikPakDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }()
}
