//
//  PersistenceProtocols.swift
//  RSSReader
//
//  Created by Адам Табиев on 24.12.2025.
//

import Foundation

// MARK: - News Persistence Protocol

/// Протокол для persistence слоя новостей
protocol NewsPersistenceProtocol {
    func fetchAll() -> [NewsItem]
    func save(_ items: [NewsItem])
    func markAsRead(_ id: String)
}

// MARK: - Sources Persistence Protocol

/// Протокол для persistence слоя источников
protocol SourcesPersistenceProtocol {
    func fetchAll() -> [RSSSource]
    func fetchEnabled() -> [RSSSource]
    func add(_ source: RSSSource)
    func toggle(_ id: String, isEnabled: Bool)
    func delete(_ id: String)
}
