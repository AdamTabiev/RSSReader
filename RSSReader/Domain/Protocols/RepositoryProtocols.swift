//
//  RepositoryProtocols.swift
//  RSSReader
//
//  Created by Адам Табиев on 24.12.2025.
//

import Foundation

// MARK: - News Repository Protocol

/// Протокол для работы с новостями
protocol NewsRepositoryProtocol {
    /// Получить все новости
    func getAllNews() async -> [NewsArticle]
    
    /// Сохранить новости
    func saveNews(_ articles: [NewsArticle]) async throws
    
    /// Пометить новость как прочитанную
    func markAsRead(_ newsId: String) async throws
}

// MARK: - Sources Repository Protocol

/// Протокол для работы с источниками
protocol SourcesRepositoryProtocol {
    /// Получить все источники
    func getAllSources() async -> [FeedSource]
    
    /// Получить только активные источники
    func getEnabledSources() async -> [FeedSource]
    
    /// Добавить источник
    func addSource(_ source: FeedSource) async throws
    
    /// Включить/выключить источник
    func toggleSource(_ sourceId: String, isEnabled: Bool) async throws
    
    /// Удалить источник
    func deleteSource(_ sourceId: String) async throws
}
