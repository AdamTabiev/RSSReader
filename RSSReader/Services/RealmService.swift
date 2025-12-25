//
//  RealmService.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import Foundation
import RealmSwift

/// Сервис для работы с локальной базой данных Realm
/// Обеспечивает сохранение, загрузку и удаление новостей и источников RSS
final class RealmService {
    
    private var realm: Realm?
        
    init() {
        do {
            realm = try Realm()
            setupDefaultSources()
            print("Realm initialized at: \(realm?.configuration.fileURL?.absoluteString ?? "unknown")")
        } catch {
            print("Realm initialization error: \(error)")
        }
    }
        
    /// Добавляет предустановленные источники при первом запуске
    private func setupDefaultSources() {
        guard let realm = realm else { return }
        
        // Проверяем, есть ли уже источники
        if realm.objects(RSSSource.self).isEmpty {
            let defaultSources = [
                RSSSource(name: "Ведомости", url: "https://www.vedomosti.ru/rss/rubric/technology/hi_tech"),
                RSSSource(name: "РБК", url: "https://rssexport.rbc.ru/rbcnews/news/30/full.rss")
            ]
            
            do {
                try realm.write {
                    for source in defaultSources {
                        realm.add(source)
                    }
                }
                print("Default sources added")
            } catch {
                print("Error adding default sources: \(error)")
            }
        }
    }
        
    /// Возвращает все новости из Realm, сортировка: от новых к старым по дате публикации
    func getAllNews() -> [NewsItem] {
        guard let realm = realm else { return [] }
        let results = realm.objects(NewsItem.self).sorted(byKeyPath: "pubDate", ascending: false)
        return Array(results)
    }
    
    /// Сохраняет массив новостей в Realm. Если новость уже есть (по id) — обновляет её
    func saveNews(_ items: [NewsItem]) {
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
    
    /// Устанавливает isRead = true для новости с указанным id
    func markAsRead(_ newsId: String) {
        guard let realm = realm else { return }
        
        if let news = realm.object(ofType: NewsItem.self, forPrimaryKey: newsId) {
            do {
                try realm.write {
                    news.isRead = true
                }
            } catch {
                print("Error marking news as read: \(error)")
            }
        }
    }
        
    /// Возвращает все RSS-источники, сортировка: по дате добавления
    func getAllSources() -> [RSSSource] {
        guard let realm = realm else { return [] }
        let results = realm.objects(RSSSource.self).sorted(byKeyPath: "dateAdded", ascending: true)
        return Array(results)
    }
    
    /// Возвращает только включённые источники (isEnabled == true)
    func getEnabledSources() -> [RSSSource] {
        guard let realm = realm else { return [] }
        let results = realm.objects(RSSSource.self)
            .filter("isEnabled == true")
            .sorted(byKeyPath: "dateAdded", ascending: true)
        return Array(results)
    }
    
    /// Добавляет новый RSS-источник в базу данных
    func addSource(_ source: RSSSource) {
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                realm.add(source)
            }
        } catch {
            print("Error adding source: \(error)")
        }
    }
    
    /// Включает или выключает источник по его id (влияет на синхронизацию)
    func toggleSource(_ sourceId: String, isEnabled: Bool) {
        guard let realm = realm else { return }
        
        if let source = realm.object(ofType: RSSSource.self, forPrimaryKey: sourceId) {
            do {
                try realm.write {
                    source.isEnabled = isEnabled
                }
            } catch {
                print("Error toggling source: \(error)")
            }
        }
    }
    
    /// Полностью удаляет RSS-источник из базы данных по его id
    func deleteSource(_ sourceId: String) {
        guard let realm = realm else { return }
        
        if let source = realm.object(ofType: RSSSource.self, forPrimaryKey: sourceId) {
            do {
                try realm.write {
                    realm.delete(source)
                }
            } catch {
                print("Error deleting source: \(error)")
            }
        }
    }
}
