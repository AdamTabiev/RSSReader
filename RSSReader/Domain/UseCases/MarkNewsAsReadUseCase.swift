//
//  MarkNewsAsReadUseCase.swift
//  RSSReader
//
//  Created by Адам Табиев on 24.12.2025.
//

import Foundation

/// Use Case: Пометить новость как прочитанную
final class MarkNewsAsReadUseCase {
    
    private let repository: NewsRepositoryProtocol
    
    init(repository: NewsRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(newsId: String) async throws {
        try await repository.markAsRead(newsId)
    }
}
