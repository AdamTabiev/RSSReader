//
//  RealmSourcesPersistence.swift
//  RSSReader
//
//  Created by Адам Табиев on 24.12.2025.
//

import Foundation
import RealmSwift

/// Реализация Persistence для источников через Realm
/// Обеспечивает CRUD-операции для RSS-источников с локальным хранением
final class RealmSourcesPersistence: SourcesPersistenceProtocol {
    
    private var realm: Realm?
    
    /// Инициализирует Realm и добавляет источники по умолчанию при первом запуске
    init() {
        do {
            realm = try Realm()
            setupDefaultSources()
        } catch {
            print("Realm init error: \(error)")
        }
    }
    
    /// Добавляет предустановленные источники при первом запуске
    /// Проверяет пустоту БД и добавляет "Ведомости" и "РБК" как стартовые источники
    private func setupDefaultSources() {
        guard let realm = realm else { return }
        
        // Добавляем только если БД пуста (первый запуск)
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
            } catch {
                print("Error adding default sources: \(error)")
            }
        }
    }
    
    /// Возвращает все источники, отсортированные по дате добавления
    func fetchAll() -> [RSSSource] {
        guard let realm = realm else { return [] }
        let results = realm.objects(RSSSource.self).sorted(byKeyPath: "dateAdded", ascending: true)
        return Array(results)
    }
    
    /// Возвращает только включённые источники (isEnabled == true)
    /// Используется для загрузки новостей только из активных источников
    func fetchEnabled() -> [RSSSource] {
        guard let realm = realm else { return [] }
        let results = realm.objects(RSSSource.self)
            .filter("isEnabled == true")
            .sorted(byKeyPath: "dateAdded", ascending: true)
        return Array(results)
    }
    
    /// Добавляет новый источник в БД
    /// Realm автоматически генерирует id через UUID
    func add(_ source: RSSSource) {
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                realm.add(source)
            }
        } catch {
            print("Error adding source: \(error)")
        }
    }
    
    /// Переключает статус источника (вкл/выкл)
    /// Находит объект по primaryKey (id) и обновляет isEnabled
    func toggle(_ id: String, isEnabled: Bool) {
        guard let realm = realm else { return }
        
        if let source = realm.object(ofType: RSSSource.self, forPrimaryKey: id) {
            do {
                try realm.write {
                    source.isEnabled = isEnabled
                }
            } catch {
                print("Error toggling source: \(error)")
            }
        }
    }
    
    /// Удаляет источник из БД по id
    /// Находит объект по primaryKey и удаляет из Realm
    func delete(_ id: String) {
        guard let realm = realm else { return }
        
        if let source = realm.object(ofType: RSSSource.self, forPrimaryKey: id) {
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
