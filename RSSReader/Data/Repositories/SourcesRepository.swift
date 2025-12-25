//
//  SourcesRepository.swift
//  RSSReader
//
//  Created by Адам Табиев on 24.12.2025.
//

import Foundation

/// Репозиторий для работы с источниками RSS
/// Служит прослойкой между Domain и Data слоями (Clean Architecture)
/// Преобразует Domain модели (FeedSource) ↔ Persistence модели (RSSSource)
final class SourcesRepository: SourcesRepositoryProtocol {
    
    /// Сервис персистентности (Realm, CoreData и т.д.)
    private let persistenceService: SourcesPersistenceProtocol
    
    /// Инициализация с DI — позволяет подменять реализацию для тестов
    init(persistenceService: SourcesPersistenceProtocol) {
        self.persistenceService = persistenceService
    }
    
    /// Возвращает все источники, преобразуя RSSSource → FeedSource
    func getAllSources() async -> [FeedSource] {
        let realmSources = persistenceService.fetchAll()
        return realmSources.map { $0.toDomainModel() }
    }
    
    /// Возвращает только активные источники для загрузки новостей
    func getEnabledSources() async -> [FeedSource] {
        let realmSources = persistenceService.fetchEnabled()
        return realmSources.map { $0.toDomainModel() }
    }
    
    /// Добавляет новый источник, преобразуя FeedSource → RSSSource
    func addSource(_ source: FeedSource) async throws {
        let realmSource = RSSSource.fromDomain(source)
        persistenceService.add(realmSource)
    }
    
    /// Переключает статус источника по id (вкл/выкл)
    func toggleSource(_ sourceId: String, isEnabled: Bool) async throws {
        persistenceService.toggle(sourceId, isEnabled: isEnabled)
    }
    
    /// Удаляет источник по id
    func deleteSource(_ sourceId: String) async throws {
        persistenceService.delete(sourceId)
    }
}
