//
//  SourcesListViewModel.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel для управления списком источников RSS
/// Работает через Use Cases для изоляции бизнес-логики
final class SourcesListViewModel: ObservableObject {
        
    /// Список всех источников
    @Published var sources: [FeedSource] = []
    /// Состояние загрузки (при валидации нового источника)
    @Published var isLoading: Bool = false
    /// Сообщение об ошибке
    @Published var errorMessage: String?
        
    private let sourcesRepository: SourcesRepositoryProtocol
    private let addSourceUseCase: AddSourceUseCase
    private let toggleSourceUseCase: ToggleSourceUseCase
    private let deleteSourceUseCase: DeleteSourceUseCase
        
    init(
        sourcesRepository: SourcesRepositoryProtocol,
        addSourceUseCase: AddSourceUseCase,
        toggleSourceUseCase: ToggleSourceUseCase,
        deleteSourceUseCase: DeleteSourceUseCase
    ) {
        self.sourcesRepository = sourcesRepository
        self.addSourceUseCase = addSourceUseCase
        self.toggleSourceUseCase = toggleSourceUseCase
        self.deleteSourceUseCase = deleteSourceUseCase
        
        Task {
            await loadSources()
        }
    }
        
    /// Загрузить источники из базы
    func loadSources() async {
        let allSources = await sourcesRepository.getAllSources()
        await MainActor.run {
            self.sources = allSources
        }
    }
    
    /// Переключить активность источника
    func toggleSource(_ source: FeedSource) {
        Task {
            try? await toggleSourceUseCase.execute(sourceId: source.id, isEnabled: !source.isEnabled)
            await loadSources()
        }
    }
    
    /// Удалить источник
    func deleteSource(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let source = sources[index]
                try? await deleteSourceUseCase.execute(sourceId: source.id)
            }
            await loadSources()
        }
    }
    
    /// Добавить новый источник после валидации
    func addSource(name: String, url: String) async -> Bool {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            try await addSourceUseCase.execute(name: name, url: url)
            await loadSources()
            await MainActor.run {
                isLoading = false
            }
            return true
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
            return false
        }
    }
}
