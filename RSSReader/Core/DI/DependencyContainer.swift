//
//  DependencyContainer.swift
//  RSSReader
//
//  Created by Адам Табиев on 24.12.2025.
//

import Foundation

/// Контейнер зависимостей приложения (Composition Root)
/// Централизованно создаёт и хранит все зависимости
/// Использует lazy инициализацию для отложенного создания объектов
final class DependencyContainer {
    
    // MARK: - Services (живут весь lifecycle приложения)
    
    /// Сервис для HTTP-запросов с retry-логикой
    lazy var networkService: NetworkServiceProtocol = {
        NetworkService()
    }()
    
    /// Парсер RSS/XML фидов
    lazy var parserService: RSSParserProtocol = {
        RSSParserService()
    }()
    
    /// Сервис настроек (UserDefaults wrapper)
    lazy var settingsService: SettingsServiceProtocol = {
        SettingsService()
    }()
    
    // MARK: - Persistence (приватные — доступ только через репозитории)
    
    /// Realm-хранилище для новостей
    private lazy var newsPersistenceService: NewsPersistenceProtocol = {
        RealmNewsPersistence()
    }()
    
    /// Realm-хранилище для источников
    private lazy var sourcesPersistenceService: SourcesPersistenceProtocol = {
        RealmSourcesPersistence()
    }()
    
    // MARK: - Repositories (прослойка Domain ↔ Data)
    
    /// Репозиторий новостей с маппингом моделей
    lazy var newsRepository: NewsRepositoryProtocol = {
        NewsRepository(persistenceService: newsPersistenceService)
    }()
    
    /// Репозиторий источников с маппингом моделей
    lazy var sourcesRepository: SourcesRepositoryProtocol = {
        SourcesRepository(persistenceService: sourcesPersistenceService)
    }()
    
    // MARK: - Use Cases Factories (создаются при каждом вызове)
    
    /// Фабрика UseCase для загрузки новостей из всех активных источников
    func makeFetchNewsUseCase() -> FetchNewsUseCase {
        FetchNewsUseCase(
            newsRepository: newsRepository,
            sourcesRepository: sourcesRepository,
            networkService: networkService,
            parserService: parserService
        )
    }
    
    /// Фабрика UseCase для пометки новости как прочитанной
    func makeMarkNewsAsReadUseCase() -> MarkNewsAsReadUseCase {
        MarkNewsAsReadUseCase(repository: newsRepository)
    }
    
    /// Фабрика UseCase для добавления нового источника
    func makeAddSourceUseCase() -> AddSourceUseCase {
        AddSourceUseCase(
            repository: sourcesRepository,
            networkService: networkService
        )
    }
    
    /// Фабрика UseCase для переключения статуса источника
    func makeToggleSourceUseCase() -> ToggleSourceUseCase {
        ToggleSourceUseCase(repository: sourcesRepository)
    }
    
    /// Фабрика UseCase для удаления источника
    func makeDeleteSourceUseCase() -> DeleteSourceUseCase {
        DeleteSourceUseCase(repository: sourcesRepository)
    }
    
    // MARK: - Routers & Services
    
    /// Роутер для навигации между экранами
    lazy var appRouter: AppRouter = {
        AppRouter()
    }()
    
    /// Сервис автообновления по таймеру
    lazy var timerService: TimerService = {
        TimerService()
    }()
    
    // MARK: - ViewModel Factories (создают готовые ViewModel'ы для View)
    
    /// Фабрика ViewModel для ленты новостей
    func makeNewsFeedViewModel() -> NewsFeedViewModel {
        NewsFeedViewModel(
            fetchNewsUseCase: makeFetchNewsUseCase(),
            markAsReadUseCase: makeMarkNewsAsReadUseCase(),
            newsRepository: newsRepository
        )
    }
    
    /// Фабрика ViewModel для настроек
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(settingsService: settingsService)
    }
    
    /// Фабрика ViewModel для списка источников
    func makeSourcesListViewModel() -> SourcesListViewModel {
        SourcesListViewModel(
            sourcesRepository: sourcesRepository,
            addSourceUseCase: makeAddSourceUseCase(),
            toggleSourceUseCase: makeToggleSourceUseCase(),
            deleteSourceUseCase: makeDeleteSourceUseCase()
        )
    }
}
