//
//  NewsSyncService.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import Foundation

// MARK: - News Sync Service

/// Сервис для синхронизации новостей между сетью и локальной базой данных
final class NewsSyncService {
        
    private let realmService: RealmService
    private let networkService: NetworkService
    private let parserService: RSSParserService
    
    
    init(realmService: RealmService = RealmService(),
         networkService: NetworkService = NetworkService(),
         parserService: RSSParserService = RSSParserService()) {
        self.realmService = realmService
        self.networkService = networkService
        self.parserService = parserService
    }
        
    /// Синхронизировать новости из всех активных источников
    func syncAllSources() async {
        let sources = realmService.getEnabledSources()
        var allParsedItems: [ParsedNewsItem] = []
        
        for source in sources {
            do {
                let data = try await networkService.fetchData(from: source.url)
                let items = parserService.parse(data: data, sourceName: source.name)
                allParsedItems.append(contentsOf: items)
                print("Synced \(items.count) items from \(source.name)")
            } catch {
                print("Sync error for \(source.name): \(error.localizedDescription)")
            }
        }
        
        // Маппинг и сохранение
        let newsItems = allParsedItems.map { $0.toNewsItem() }
        realmService.saveNews(newsItems)
    }
}
