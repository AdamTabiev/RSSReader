//
//  ManageSourcesUseCases.swift
//  RSSReader
//
//  Created by Адам Табиев on 24.12.2025.
//

import Foundation

/// Use Case: Включить/выключить источник
final class ToggleSourceUseCase {
    
    private let repository: SourcesRepositoryProtocol
    
    init(repository: SourcesRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(sourceId: String, isEnabled: Bool) async throws {
        try await repository.toggleSource(sourceId, isEnabled: isEnabled)
    }
}

/// Use Case: Удалить источник
final class DeleteSourceUseCase {
    
    private let repository: SourcesRepositoryProtocol
    
    init(repository: SourcesRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(sourceId: String) async throws {
        try await repository.deleteSource(sourceId)
    }
}
