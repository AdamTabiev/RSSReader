//
//  SettingsViewModel.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel для управления настройками приложения
final class SettingsViewModel: ObservableObject {
        
    /// Частота обновления в минутах (сохраняется через SettingsService)
    @Published var refreshInterval: Int {
        didSet {
            settingsService.refreshInterval = refreshInterval
        }
    }
    
    /// Состояние очистки кэша
    @Published var cacheSize: String = "0 MB"
        
    private let settingsService: SettingsServiceProtocol
        
    init(settingsService: SettingsServiceProtocol) {
        self.settingsService = settingsService
        // Загружаем интервал из настроек
        self.refreshInterval = settingsService.refreshInterval
        
        updateCacheSize()
    }
        
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
