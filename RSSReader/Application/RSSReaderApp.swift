//
//  RSSReaderApp.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import SwiftUI

@main
struct RSSReaderApp: App {
    
    /// Контейнер зависимостей (Composition Root)
    private let container = DependencyContainer()
    
    /// Управляет навигацией между экранами
    @StateObject private var appRouter = AppRouter()
    
    /// Таймер автообновления новостей
    @StateObject private var timerService = TimerService()
    
    /// Работа с локальной базой Realm (новости, источники)
    private let realmService = RealmService()
    
    /// Синхронизация новостей из RSS-лент
    private let syncService = NewsSyncService()
    
    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .environmentObject(appRouter)
                .environmentObject(timerService)
                .onAppear {
                    setupTimer()
                }
        }
    }
    
    /// Связывает таймер с сервисом синхронизации (размещён здесь как точка инициализации)
    private func setupTimer() {
        timerService.onTimerTick = {
            Task {
                await syncService.syncAllSources()
            }
        }
    }
}
