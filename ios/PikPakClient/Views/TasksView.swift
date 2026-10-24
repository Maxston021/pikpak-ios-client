//
//  TasksView.swift
//  PikPakClient
//
//  离线下载任务列表
//

import SwiftUI

struct TasksView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var tasks: [TaskItem] = []
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            List {
                if tasks.isEmpty && !isLoading {
                    Text("暂无下载任务")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                }
                
                ForEach(tasks) { task in
                    TaskRowView(task: task)
                }
            }
            .navigationTitle("下载任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                Task {
                    await loadTasks()
                }
            }
            .onReceive(timer) { _ in
                Task {
                    await loadTasks()
                }
            }
        }
    }
    
    private func loadTasks() async {
        do {
            let result = try await APIService.shared.listTasks(
                accessToken: authManager.accessToken
            )
            
            await MainActor.run {
                self.tasks = result.tasks
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}

// MARK: - 任务行视图
struct TaskRowView: View {
    let task: TaskItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text(task.statusText)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(4)
            }
            
            if task.status == "RUNNING" {
                ProgressView(value: Double(task.progress), total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                
                Text("\(task.progress)%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch task.status {
        case "PENDING": return .orange
        case "RUNNING": return .blue
        case "COMPLETED": return .green
        case "ERROR": return .red
        default: return .gray
        }
    }
}

#Preview {
    TasksView()
}
