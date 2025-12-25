//
//  NewsRowView.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import SwiftUI

/// Ячейка отдельной новости в общем списке
/// Поддерживает два режима отображения данных (обычный и подробный)
struct NewsRowView: View {
    
    let newsItem: NewsArticle
    let displayMode: DisplayMode
        
    private let imageSize = CGSize(width: 80, height: 80)
        
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Картинка
            CachedImageView(
                urlString: newsItem.imageURL,
                size: imageSize
            )
            
            // Текст
            VStack(alignment: .leading, spacing: 4) {
                // Заголовок + источник
                HStack(alignment: .top) {
                    Text(newsItem.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(newsItem.isRead ? .gray : .primary)
                        .lineLimit(displayMode == .regular ? 3 : nil)
                    
                    Spacer()
                    
                    // Источник
                    Text(newsItem.sourceName)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                
                // Описание (только в extended режиме)
                if displayMode == .extended && !newsItem.description.isEmpty {
                    Text(newsItem.description)
                        .font(.system(size: 13))
                        .foregroundStyle(newsItem.isRead ? .gray : .secondary)
                        .lineLimit(4)
                        .padding(.top, 2)
                }
                
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview("Regular") {
    let item = NewsArticle(
        id: "1",
        title: "Заголовок новости достаточно длинный для проверки",
        description: "Краткое описание новости для отображения в расширенном режиме",
        imageURL: nil,
        link: "https://example.com",
        pubDate: Date().addingTimeInterval(-3600),
        sourceName: "РБК"
    )
    
    return NewsRowView(newsItem: item, displayMode: .regular)
        .padding()
}

#Preview("Extended") {
    let item = NewsArticle(
        id: "1",
        title: "Заголовок новости",
        description: "Краткое описание новости для отображения в расширенном режиме. Это многострочный текст.",
        imageURL: nil,
        link: "https://example.com",
        pubDate: Date().addingTimeInterval(-7200),
        sourceName: "Ведомости"
    )
    
    return NewsRowView(newsItem: item, displayMode: .extended)
        .padding()
}
