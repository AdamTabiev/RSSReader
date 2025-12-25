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
/// Работает через Use Cases для изоляции бизнес-логики
final class NewsFeedViewModel: ObservableObject {
        
    /// Список новостей для отображения
    @Published var news: [NewsArticle] = []
    /// Состояние загрузки данных из сети
    @Published var isLoading: Bool = false
    /// Текущий режим отображения (обычный/расширенный)
    @Published var displayMode: DisplayMode = .regular
    /// Сообщение об ошибке (если есть)
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let fetchNewsUseCase: FetchNewsUseCase
    private let markAsReadUseCase: MarkNewsAsReadUseCase
    private let newsRepository: NewsRepositoryProtocol
        
    init(
        fetchNewsUseCase: FetchNewsUseCase,
        markAsReadUseCase: MarkNewsAsReadUseCase,
        newsRepository: NewsRepositoryProtocol
    ) {
        self.fetchNewsUseCase = fetchNewsUseCase
        self.markAsReadUseCase = markAsReadUseCase
        self.newsRepository = newsRepository
        
        Task {
            await loadFromDatabase()
        }
    }
        
    /// Загрузить новости из базы данных
    func loadFromDatabase() async {
        let articles = await newsRepository.getAllNews()
        await MainActor.run {
            self.news = articles
        }
    }
    
    /// Загрузить новости из сети (с параллельной загрузкой источников)
    func refreshNews() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            _ = try await fetchNewsUseCase.execute()
            await loadFromDatabase()
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    /// Пометить новость как прочитанную
    func markAsRead(_ article: NewsArticle) {
        Task {
            try? await markAsReadUseCase.execute(newsId: article.id)
            await loadFromDatabase()
        }
    }
    
    /// Переключить режим отображения
    func toggleDisplayMode() {
        displayMode = displayMode == .regular ? .extended : .regular
    }
}
