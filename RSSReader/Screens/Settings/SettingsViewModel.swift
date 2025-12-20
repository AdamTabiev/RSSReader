//
//  SettingsViewModel.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Settings ViewModel

/// ViewModel для управления настройками приложения
final class SettingsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Частота обновления в минутах (сохраняется в UserDefaults)
    @Published var refreshInterval: Int {
        didSet {
            UserDefaults.standard.set(refreshInterval, forKey: "refreshInterval")
        }
    }
    
    /// Состояние очистки кэша
    @Published var cacheSize: String = "0 MB"
    
    // MARK: - Dependencies
    
    private let realmService: RealmService
    
    // MARK: - Init
    
    init(realmService: RealmService = RealmService()) {
        self.realmService = realmService
        // Загружаем интервал из настроек (по умолчанию 30 мин)
        self.refreshInterval = UserDefaults.standard.integer(forKey: "refreshInterval")
        if self.refreshInterval == 0 { self.refreshInterval = 30 }
        
        updateCacheSize()
    }
    
    // MARK: - Public Methods
    
    /// Обновить информацию о размере кэша
    func updateCacheSize() {
        cacheSize = ImageCacheService.shared.cacheSize()
    }
    
    /// Очистить кэш картинок
    func clearCache() {
        ImageCacheService.shared.clearCache()
        updateCacheSize()
    }
    
    /// Форматированный текст интервала
    var refreshIntervalText: String {
        if refreshInterval < 60 {
            return "\(refreshInterval) мин"
        } else {
            let hours = refreshInterval / 60
            return "\(hours) ч"
        }
    }
}
