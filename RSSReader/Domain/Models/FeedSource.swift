//
//  FeedSource.swift
//  RSSReader
//
//  Created by Адам Табиев on 24.12.2025.
//

import Foundation

/// Чистая доменная модель источника RSS
struct FeedSource: Identifiable, Hashable {
    let id: String
    let name: String
    let url: String
    let isEnabled: Bool
    let dateAdded: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        url: String,
        isEnabled: Bool = true,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.isEnabled = isEnabled
        self.dateAdded = dateAdded
    }
}
