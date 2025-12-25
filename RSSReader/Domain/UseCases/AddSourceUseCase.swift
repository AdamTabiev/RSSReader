//
//  AddSourceUseCase.swift
//  RSSReader
//
//  Created by Адам Табиев on 24.12.2025.
//

import Foundation

/// Use Case: Добавить новый RSS источник с валидацией
final class AddSourceUseCase {
    
    private let repository: SourcesRepositoryProtocol
    private let networkService: NetworkServiceProtocol
    
    init(
        repository: SourcesRepositoryProtocol,
        networkService: NetworkServiceProtocol
    ) {
        self.repository = repository
        self.networkService = networkService
    }
    
    /// Добавить источник с валидацией RSS feed
    func execute(name: String, url: String) async throws {
        // Валидация RSS feed
        let isValid = await networkService.isValidRSSFeed(urlString: url)
        
        guard isValid else {
            throw SourceError.invalidRSSFeed
        }
        
        let source = FeedSource(name: name, url: url)
        try await repository.addSource(source)
    }
}

enum SourceError: Error, LocalizedError {
    case invalidRSSFeed
    
    var errorDescription: String? {
        switch self {
        case .invalidRSSFeed:
            return "Указанный URL не является валидным RSS источником"
        }
    }
}
