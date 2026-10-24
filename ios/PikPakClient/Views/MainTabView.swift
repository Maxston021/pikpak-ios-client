//
//  MainTabView.swift
//  PikPakClient
//
//  主界面 Tab 视图
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            OfflineDownloadView(folderId: "root")
                .tabItem {
                    Image(systemName: "plus.app")
                    Text("离线下载")
                }
            
            TasksView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("下载任务")
                }
        }
    }
}
