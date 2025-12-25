//
//  SettingsService.swift
//  RSSReader
//
//  Created by Адам Табиев on 24.12.2025.
//

import Foundation
import Combine

/// Сервис для управления настройками приложения
final class SettingsService: ObservableObject, SettingsServiceProtocol {
    
    @Published var refreshInterval: Int {
        didSet {
            userDefaults.set(refreshInterval, forKey: Keys.refreshInterval)
        }
    }
    
    private let userDefaults: UserDefaults
    
    private enum Keys {
        static let refreshInterval = "refreshInterval"
    }
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.refreshInterval = userDefaults.integer(forKey: Keys.refreshInterval)
        
        // Если не установлен - дефолт 30 минут
        if self.refreshInterval == 0 {
            self.refreshInterval = 30
        }
    }
}
