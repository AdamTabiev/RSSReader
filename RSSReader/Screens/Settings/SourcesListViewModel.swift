//
//  SourcesListViewModel.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Sources List ViewModel

/// ViewModel для управления списком источников RSS
final class SourcesListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Список всех источников
    @Published var sources: [RSSSource] = []
    /// Состояние загрузки (при валидации нового источника)
    @Published var isLoading: Bool = false
    /// Сообщение об ошибке
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let realmService: RealmService
    private let networkService: NetworkService
    
    // MARK: - Init
    
    init(realmService: RealmService = RealmService(),
         networkService: NetworkService = NetworkService()) {
        self.realmService = realmService
        self.networkService = networkService
        loadSources()
    }
    
    // MARK: - Public Methods
    
    /// Загрузить источники из базы
    func loadSources() {
        sources = realmService.getAllSources()
    }
    
    /// Переключить активность источника
    func toggleSource(_ source: RSSSource) {
        realmService.toggleSource(source.id, isEnabled: !source.isEnabled)
        loadSources()
    }
    
    /// Удалить источник
    func deleteSource(at offsets: IndexSet) {
        offsets.forEach { index in
            let source = sources[index]
            realmService.deleteSource(source.id)
        }
        loadSources()
    }
    
    /// Добавить новый источник после валидации
    func addSource(name: String, url: String) async -> Bool {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let isValid = await networkService.validateRSSURL(url)
        
        if isValid {
            let newSource = RSSSource(name: name, url: url)
            realmService.addSource(newSource)
            await MainActor.run {
                loadSources()
                isLoading = false
            }
            return true
        } else {
            await MainActor.run {
                errorMessage = "Неверный URL или не является RSS-лентой"
                isLoading = false
            }
            return false
        }
    }
}
