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
            Group {
                if authManager.isLoggedIn {
                    Text("Logged In!")
                } else {
                    Text("Login View Placeholder")
                }
            }
            .environmentObject(authManager)
        }
    }
}
