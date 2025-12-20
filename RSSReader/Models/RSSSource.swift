//
//  RSSSource.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import Foundation
import RealmSwift

// MARK: - RSS Source

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
