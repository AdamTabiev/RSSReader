//
//  RealmNewsPersistence.swift
//  RSSReader
//
//  Created by Адам Табиев on 24.12.2025.
//

import Foundation
import RealmSwift

/// Реализация Persistence для новостей через Realm
/// Обеспечивает CRUD-операции для новостей с локальным хранением
final class RealmNewsPersistence: NewsPersistenceProtocol {
    
    private var realm: Realm?
    
    /// Инициализирует Realm для работы с новостями
    init() {
        do {
            realm = try Realm()
        } catch {
            print("Realm init error: \(error)")
        }
    }
    
    /// Возвращает все новости, отсортированные по дате (новые первыми)
    func fetchAll() -> [NewsItem] {
        guard let realm = realm else { return [] }
        let results = realm.objects(NewsItem.self).sorted(byKeyPath: "pubDate", ascending: false)
        return Array(results)
    }
    
    /// Сохраняет массив новостей с политикой update: .modified
    /// Если новость с таким id существует — обновляет, иначе добавляет новую
    func save(_ items: [NewsItem]) {
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                for item in items {
                    realm.add(item, update: .modified)
                }
            }
        } catch {
            print("Error saving news: \(error)")
        }
    }
    
    /// Помечает новость как прочитанную по id
    /// Находит объект по primaryKey и устанавливает isRead = true
    func markAsRead(_ id: String) {
        guard let realm = realm else { return }
        
        if let news = realm.object(ofType: NewsItem.self, forPrimaryKey: id) {
            do {
                try realm.write {
                    news.isRead = true
                }
            } catch {
                print("Error marking as read: \(error)")
            }
        }
    }
}
