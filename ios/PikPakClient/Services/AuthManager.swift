//
//  AuthManager.swift
//  PikPakClient
//
//  认证状态管理
//

import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isLoggedIn = false
    @Published var accessToken: String = ""
    @Published var refreshToken: String = ""
    @Published var user: User?
    
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "pikpak_access_token"
    private let refreshKey = "pikpak_refresh_token"
    private let userKey = "pikpak_user"
    
    private init() {
        loadSavedTokens()
    }
    
    // 加载本地保存的 token
    private func loadSavedTokens() {
        if let token = userDefaults.string(forKey: tokenKey),
           let refresh = userDefaults.string(forKey: refreshKey) {
            self.accessToken = token
            self.refreshToken = refresh
            self.isLoggedIn = true
            
            if let userData = userDefaults.data(forKey: userKey),
               let savedUser = try? JSONDecoder().decode(User.self, from: userData) {
                self.user = savedUser
            }
        }
    }
    
    // 登录成功后保存
    func saveLoginResponse(_ response: LoginResponse) {
        self.accessToken = response.accessToken
        self.refreshToken = response.refreshToken
        self.user = response.user
        self.isLoggedIn = true
        
        userDefaults.set(response.accessToken, forKey: tokenKey)
        userDefaults.set(response.refreshToken, forKey: refreshKey)
        
        let userData = try? JSONEncoder().encode(response.user)
        if let userData = userData {
            userDefaults.set(userData, forKey: userKey)
        }
    }
    
    // 登出
    func logout() {
        self.accessToken = ""
        self.refreshToken = ""
        self.user = nil
        self.isLoggedIn = false
        
        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: refreshKey)
        userDefaults.removeObject(forKey: userKey)
    }
}
