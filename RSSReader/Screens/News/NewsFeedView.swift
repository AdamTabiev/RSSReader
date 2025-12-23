//
//  NewsFeedView.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import SwiftUI

// MARK: - News Feed View

/// Главный экран с лентой новостей
struct NewsFeedView: View {
    
    @EnvironmentObject private var appRouter: AppRouter
    @StateObject private var viewModel = NewsFeedViewModel()
    
    var body: some View {
        NavigationStack(path: $appRouter.newsRoute) {
            ZStack {
                if viewModel.news.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    newsListView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Кнопка обновления (слева)
                ToolbarItem(placement: .navigationBarLeading) {
                    refreshButton
                }
                
                // Segmented Control (центр)
                ToolbarItem(placement: .principal) {
                    displayModePicker
                }
                
                // Кнопка настроек (справа)
                ToolbarItem(placement: .navigationBarTrailing) {
                    settingsButton
                }
            }
            .navigationDestination(for: NewsScreen.self) { screen in
                switch screen {
                case .detail(let url):
                    NewsDetailView(urlString: url)
                case .settings:
                    SettingsMainView()
                case .sources:
                    SourcesListView()
                }
            }
        }
        .onAppear {
            // Актуализация данных при возврате с других экранов
            viewModel.loadFromDatabase()
        }
        .task {
            // Загрузка новостей при первом появлении
            await viewModel.refreshNews()
        }
    }
    
    // MARK: - News List
    
    private var newsListView: some View {
        List {
            ForEach(viewModel.news) { newsItem in
                Button {
                    // Пометить как прочитанную и открыть
                    viewModel.markAsRead(newsItem)
                    appRouter.newsRoute.append(.detail(url: newsItem.link))
                } label: {
                    NewsRowView(
                        newsItem: newsItem,
                        displayMode: viewModel.displayMode
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.5))
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            
            Text("Нет новостей")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text("Нажмите кнопку обновления")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
    }
    
    // MARK: - Toolbar Items
    
    private var refreshButton: some View {
        RefreshButtonView(isLoading: viewModel.isLoading) {
            Task {
                await viewModel.refreshNews()
            }
        }
    }
    
    private var displayModePicker: some View {
        DisplayModePickerView(displayMode: $viewModel.displayMode)
    }
    
    private var settingsButton: some View {
        SettingsButtonView {
            appRouter.newsRoute.append(.settings)
        }
    }
}

#Preview {
    NewsFeedView()
        .environmentObject(AppRouter())
}
