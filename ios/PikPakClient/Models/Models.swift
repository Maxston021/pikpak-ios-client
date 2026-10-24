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
