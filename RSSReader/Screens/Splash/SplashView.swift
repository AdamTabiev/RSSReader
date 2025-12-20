//
//  SplashView.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import SwiftUI

// MARK: - Splash View

/// Splash экран приложения
/// Показывается при запуске на 2 секунды с логотипом и индикатором загрузки
struct SplashView: View {
    
    @EnvironmentObject private var appRouter: AppRouter
    
    // MARK: - State
    
    @State private var showProgress: Bool = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Фон
            Color.white
                .ignoresSafeArea()
            
            // Логотип в центре
            VStack {
                Spacer()
                logoView
                Spacer()
            }
            
            // Лоадер внизу
            if showProgress {
                VStack {
                    Spacer()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                        .scaleEffect(1.2)
                    
                    Spacer()
                        .frame(height: 100)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            startSplash()
        }
    }
    
    // MARK: - Logo View
    
    private var logoView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(.orange)
                .frame(width: 120, height: 120)
            
            Image(systemName: "newspaper.fill")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(.white)
        }
        .scaleEffect(logoScale)
        .opacity(logoOpacity)
    }
    
    // MARK: - Private Methods
    
    private func startSplash() {
        // Показать логотип с анимацией
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Показать лоадер через 0.5 секунды
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            await MainActor.run {
                withAnimation {
                    showProgress = true
                }
            }
        }
        
        // Перейти на главный экран через 2 секунды
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                navigateToNews()
            }
        }
    }
    
    private func navigateToNews() {
        withAnimation {
            appRouter.currentScreen = .news
        }
    }
}

// MARK: - Previews

#Preview {
    SplashView()
        .environmentObject(AppRouter())
}
