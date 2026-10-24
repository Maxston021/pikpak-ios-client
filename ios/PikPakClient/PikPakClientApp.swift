//
//  PikPakClientApp.swift
//  PikPakClient
//
//  App 入口
//

import SwiftUI

@main
struct PikPakClientApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(authManager)
        }
    }
}
