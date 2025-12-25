//
//  NewsArticle.swift
//  RSSReader
//
//  Created by Адам Табиев on 24.12.2025.
//

import Foundation

/// Чистая доменная модель новости (без зависимости от Realm)
struct NewsArticle: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let imageURL: String?
    let link: String
    let pubDate: Date
    let sourceName: String
    let isRead: Bool
    
    init(
        id: String,
        title: String,
        description: String,
        imageURL: String? = nil,
        link: String,
        pubDate: Date,
        sourceName: String,
        isRead: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.link = link
        self.pubDate = pubDate
        self.sourceName = sourceName
        self.isRead = isRead
    }
}
