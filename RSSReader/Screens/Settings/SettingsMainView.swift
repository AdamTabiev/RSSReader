//
//  SettingsMainView.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import SwiftUI

// MARK: - Settings Main View

/// Главный экран настроек приложения
struct SettingsMainView: View {
    
    @EnvironmentObject private var appRouter: AppRouter
    @StateObject private var viewModel = SettingsViewModel()
    
    /// Состояние для выбора интервала
    @State private var showIntervalPicker = false
    
    /// Состояние для подтверждения очистки кэша
    @State private var showClearCacheAlert = false
    
    var body: some View {
        List {
            // Раздел управления контентом
            Section("Контент") {
                Button {
                    appRouter.newsRoute.append(.sources)
                } label: {
                    SettingsRowView(
                        title: "Источники",
                        icon: "list.bullet",
                        iconColor: .blue
                    )
                }
                .buttonStyle(.plain)
                
                Button {
                    showIntervalPicker = true
                } label: {
                    SettingsRowView(
                        title: "Обновление",
                        icon: "timer",
                        iconColor: .orange,
                        value: viewModel.refreshIntervalText
                    )
                }
                .buttonStyle(.plain)
            }
            
            // Раздел памяти
            Section("Память") {
                Button {
                    showClearCacheAlert = true
                } label: {
                    SettingsRowView(
                        title: "Очистить кэш",
                        icon: "trash",
                        iconColor: .red,
                        value: viewModel.cacheSize
                    )
                }
                .buttonStyle(.plain)
            }
            
            // Информация
            Section("О приложении") {
                HStack {
                    Text("Версия")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.updateCacheSize()
        }
        // Выбор интервала
        .confirmationDialog("Частота обновления", isPresented: $showIntervalPicker, titleVisibility: .visible) {
            Button("15 минут") { viewModel.refreshInterval = 15 }
            Button("30 минут") { viewModel.refreshInterval = 30 }
            Button("1 час") { viewModel.refreshInterval = 60 }
            Button("3 часа") { viewModel.refreshInterval = 180 }
            Button("Отмена", role: .cancel) {}
        }
        // Подтверждение очистки
        .alert("Очистить кэш?", isPresented: $showClearCacheAlert) {
            Button("Очистить", role: .destructive) {
                viewModel.clearCache()
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Все загруженные изображения будут удалены из памяти устройства.")
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        SettingsMainView()
            .environmentObject(AppRouter())
    }
}
