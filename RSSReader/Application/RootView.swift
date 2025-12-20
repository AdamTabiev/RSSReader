//
//  RootView.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import SwiftUI

// MARK: - Root View

/// Корневой view приложения
/// Переключает главные экраны через AppRouter
struct RootView: View {
    
    @EnvironmentObject private var appRouter: AppRouter
    
    var body: some View {
        Group {
            switch appRouter.currentScreen {
            case .splash:
                SplashView()
            case .news:
                NewsFeedView()
            }
        }
        .preferredColorScheme(.light) // Принудительная светлая тема
    }
}

// MARK: - Previews

#Preview {
    RootView()
        .environmentObject(AppRouter())
}
