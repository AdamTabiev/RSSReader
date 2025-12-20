//
//  AppRouter.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import SwiftUI
import Combine

/// Центральный роутер приложения для управления навигацией
final class AppRouter: ObservableObject {
    
    /// Текущий главный экран приложения
    @Published var currentScreen: AppScreen = .splash
    
    /// Стек навигации для экрана новостей
    @Published var newsRoute: [NewsScreen] = []
    
    /// Стек навигации для экрана настроек
    @Published var settingsRoute: [SettingsScreen] = []
}

/// Главные экраны приложения
enum AppScreen {
    case splash
    case news
}

/// Экраны раздела News
enum NewsScreen: Hashable {
    case detail(url: String)
    case settings
    case sources
}

/// Экраны раздела Settings
enum SettingsScreen: Hashable {
    case sources
}
