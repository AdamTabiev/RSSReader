//
//  NewsItem.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import Foundation
import RealmSwift

/// Модель отдельной новости
/// Хранится в Realm и отображается в ленте новостей
final class NewsItem: Object, Identifiable {
    
    /// Уникальный идентификатор (используется URL статьи)
    @Persisted(primaryKey: true) var id: String = ""
    
    /// Заголовок новости
    @Persisted var title: String = ""
    
    /// Краткое описание новости
    @Persisted var descriptionText: String = ""
    
    /// URL картинки
    @Persisted var imageURL: String?
    
    /// Ссылка на оригинальную статью
    @Persisted var link: String = ""
    
    /// Дата публикации
    @Persisted var pubDate: Date = Date()
    
    /// Название источника
    @Persisted var sourceName: String = ""
    
    /// Флаг прочтения
    @Persisted var isRead: Bool = false
    
    /// Convenience initializer
    convenience init(
        id: String,
        title: String,
        descriptionText: String,
        imageURL: String?,
        link: String,
        pubDate: Date,
        sourceName: String
    ) {
        self.init()
        self.id = id
        self.title = title
        self.descriptionText = descriptionText
        self.imageURL = imageURL
        self.link = link
        self.pubDate = pubDate
        self.sourceName = sourceName
    }
    
}

// MARK: - Domain Mapping

extension NewsItem {
    /// Конвертация Realm модели → Domain модель
    func toDomainModel() -> NewsArticle {
        NewsArticle(
            id: self.id,
            title: self.title,
            description: self.descriptionText,
            imageURL: self.imageURL,
            link: self.link,
            pubDate: self.pubDate,
            sourceName: self.sourceName,
            isRead: self.isRead
        )
    }
    
    /// Конвертация Domain модели → Realm модель
    static func fromDomain(_ article: NewsArticle) -> NewsItem {
        NewsItem(
            id: article.id,
            title: article.title,
            descriptionText: article.description,
            imageURL: article.imageURL,
            link: article.link,
            pubDate: article.pubDate,
            sourceName: article.sourceName
        )
    }
}

