//
//  NewsRepository.swift
//  RSSReader
//
//  Created by Адам Табиев on 24.12.2025.
//

import Foundation

/// Репозиторий для работы с новостями
/// Служит прослойкой между Domain и Data слоями (Clean Architecture)
/// Преобразует Domain модели (NewsArticle) ↔ Persistence модели (NewsItem)
final class NewsRepository: NewsRepositoryProtocol {
    
    /// Сервис персистентности для новостей
    private let persistenceService: NewsPersistenceProtocol
    
    /// Инициализация с DI — позволяет подменять реализацию для тестов
    init(persistenceService: NewsPersistenceProtocol) {
        self.persistenceService = persistenceService
    }
    
    /// Возвращает все новости, преобразуя NewsItem → NewsArticle
    func getAllNews() async -> [NewsArticle] {
        let realmItems = persistenceService.fetchAll()
        return realmItems.map { $0.toDomainModel() }
    }
    
    /// Сохраняет массив новостей, преобразуя NewsArticle → NewsItem
    func saveNews(_ articles: [NewsArticle]) async throws {
        let realmItems = articles.map { NewsItem.fromDomain($0) }
        persistenceService.save(realmItems)
    }
    
    /// Помечает новость как прочитанную по id
    func markAsRead(_ newsId: String) async throws {
        persistenceService.markAsRead(newsId)
    }
}
