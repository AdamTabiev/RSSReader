//
//  ServiceProtocols.swift
//  RSSReader
//
//  Created by Адам Табиев on 24.12.2025.
//

import Foundation

// MARK: - Network Service Protocol

/// Протокол для сетевого сервиса
protocol NetworkServiceProtocol {
    /// Загрузить данные по URL
    func fetchData(from urlString: String) async throws -> Data
    
    /// Проверить валидность RSS feed
    func isValidRSSFeed(urlString: String) async -> Bool
}

// MARK: - RSS Parser Protocol

/// Протокол для парсера RSS
protocol RSSParserProtocol {
    /// Распарсить RSS данные
    func parse(data: Data, sourceName: String) -> [ParsedNewsItem]
}

// MARK: - Settings Service Protocol

/// Протокол для сервиса настроек
protocol SettingsServiceProtocol: AnyObject {
    /// Интервал обновления в минутах
    var refreshInterval: Int { get set }
}
