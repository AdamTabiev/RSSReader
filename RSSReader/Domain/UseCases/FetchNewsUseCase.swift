//
//  FetchNewsUseCase.swift
//  RSSReader
//
//  Created by Адам Табиев on 24.12.2025.
//

import Foundation

/// Use Case: Загрузка и синхронизация новостей из всех активных источников
final class FetchNewsUseCase {
    
    private let newsRepository: NewsRepositoryProtocol
    private let sourcesRepository: SourcesRepositoryProtocol
    private let networkService: NetworkServiceProtocol
    private let parserService: RSSParserProtocol
    
    init(
        newsRepository: NewsRepositoryProtocol,
        sourcesRepository: SourcesRepositoryProtocol,
        networkService: NetworkServiceProtocol,
        parserService: RSSParserProtocol
    ) {
        self.newsRepository = newsRepository
        self.sourcesRepository = sourcesRepository
        self.networkService = networkService
        self.parserService = parserService
    }
    
    /// Синхронизировать новости из всех активных источников (параллельно)
    func execute() async throws -> [NewsArticle] {
        let sources = await sourcesRepository.getEnabledSources()
        
        // 🚀 ПАРАЛЛЕЛЬНАЯ загрузка через TaskGroup
        let allParsedItems = await withTaskGroup(
            of: [ParsedNewsItem].self,
            returning: [ParsedNewsItem].self
        ) { group in
            
            for source in sources {
                group.addTask { [weak self] in
                    guard let self = self else { return [] }
                    
                    do {
                        let data = try await self.networkService.fetchData(from: source.url)
                        let items = await self.parserService.parse(data: data, sourceName: source.name)
                        print("✅ Synced \(items.count) items from \(source.name)")
                        return items
                    } catch {
                        print("❌ Sync error for \(source.name): \(error.localizedDescription)")
                        return []
                    }
                }
            }
            
            var allItems: [ParsedNewsItem] = []
            for await items in group {
                allItems.append(contentsOf: items)
            }
            return allItems
        }
        
        // Маппинг ParsedNewsItem → NewsArticle
        let articles = allParsedItems.map { $0.toDomainModel() }
        
        // Сохранение в репозиторий
        try await newsRepository.saveNews(articles)
        
        return articles
    }
}
