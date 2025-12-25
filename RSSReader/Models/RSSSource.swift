//
//  RSSSource.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import Foundation
import RealmSwift

/// Модель источника новостей (например, РБК или Ведомости)
/// Позволяет хранить URL ленты и статус активности источника
final class RSSSource: Object, Identifiable {
    
    /// Уникальный идентификатор источника
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    
    /// Название источника
    @Persisted var name: String = ""
    
    /// URL RSS-ленты
    @Persisted var url: String = ""
    
    /// Включён ли источник
    @Persisted var isEnabled: Bool = true
    
    /// Дата добавления
    @Persisted var dateAdded: Date = Date()
    
    /// Convenience initializer
    convenience init(name: String, url: String) {
        self.init()
        self.id = UUID().uuidString
        self.name = name
        self.url = url
    }
    
}

// MARK: - Domain Mapping

extension RSSSource {
    /// Конвертация Realm модели → Domain модель
    func toDomainModel() -> FeedSource {
        FeedSource(
            id: self.id,
            name: self.name,
            url: self.url,
            isEnabled: self.isEnabled,
            dateAdded: self.dateAdded
        )
    }
    
    /// Конвертация Domain модели → Realm модель
    static func fromDomain(_ source: FeedSource) -> RSSSource {
        let realmSource = RSSSource(name: source.name, url: source.url)
        realmSource.id = source.id
        realmSource.isEnabled = source.isEnabled
        realmSource.dateAdded = source.dateAdded
        return realmSource
    }
}

