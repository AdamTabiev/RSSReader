//
//  NewsFeedViewModel.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import Foundation
import SwiftUI
import Combine

/// Режим отображения новостей
enum DisplayMode: String, CaseIterable {
    case regular
    case extended
}

/// ViewModel для управления состоянием ленты новостей
/// Отвечает за координацию между базой данных, сетью и парсером
final class NewsFeedViewModel: ObservableObject {
        
    /// Список новостей для отображения
    @Published var news: [NewsItem] = []
    /// Состояние загрузки данных из сети
    @Published var isLoading: Bool = false
    /// Текущий режим отображения (обычный/расширенный)
    @Published var displayMode: DisplayMode = .regular
    /// Сообщение об ошибке (если есть)
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let realmService: RealmService
    private let syncService: NewsSyncService
        
    init(realmService: RealmService = RealmService(), syncService: NewsSyncService = NewsSyncService()) {
        self.realmService = realmService
        self.syncService = syncService
        
        // Загружаем новости из базы данных
        loadFromDatabase()
    }
        
    /// Загрузить новости из базы данных
    func loadFromDatabase() {
        news = realmService.getAllNews()
    }
    
    /// Загрузить новости из сети
    func refreshNews() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        await syncService.syncAllSources()
        
        await MainActor.run {
            loadFromDatabase()
            isLoading = false
        }
    }
    
    /// Пометить новость как прочитанную
    func markAsRead(_ newsItem: NewsItem) {
        realmService.markAsRead(newsItem.id)
        loadFromDatabase()
    }
    
    /// Переключить режим отображения
    func toggleDisplayMode() {
        displayMode = displayMode == .regular ? .extended : .regular
    }
}
