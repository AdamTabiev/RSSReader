//
//  ImageCacheService.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import UIKit

// MARK: - Image Cache Service

/// Сервис для кэширования изображений
/// Использует два уровня кэширования: в оперативной памяти и на диске
final class ImageCacheService {
    
    /// Синглтон для доступа к сервису
    static let shared = ImageCacheService()
    
    /// Менеджер файлов для работы с дисковым кэшем
    private let fileManager = FileManager.default
    /// Путь к директории кэша на диске
    private let cacheDirectory: URL
    /// Кэш в оперативной памяти для быстрого доступа
    private let memoryCache = NSCache<NSString, UIImage>()
        
    private init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache", isDirectory: true)
        
        // Создаём директорию если её нет
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        
        // Настройка memory cache
        memoryCache.countLimit = 100
    }
        
    /// Загрузить картинку (из кэша или сети)
    func loadImage(from urlString: String) async -> UIImage? {
        let key = cacheKey(for: urlString)
        
        // 1. Проверяем memory cache
        if let cached = memoryCache.object(forKey: key as NSString) {
            return cached
        }
        
        // 2. Проверяем disk cache
        if let diskImage = loadFromDisk(key: key) {
            memoryCache.setObject(diskImage, forKey: key as NSString)
            return diskImage
        }
        
        // 3. Загружаем из сети
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            
            // Сохраняем в кэш
            memoryCache.setObject(image, forKey: key as NSString)
            saveToDisk(image: image, key: key)
            
            return image
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
    }
    
    /// Очистить весь кэш
    func clearCache() {
        // Очищаем memory cache
        memoryCache.removeAllObjects()
        
        // Очищаем disk cache
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try fileManager.removeItem(at: file)
            }
            print("Cache cleared")
        } catch {
            print("Error clearing cache: \(error)")
        }
    }
    
    /// Получить размер кэша
    func cacheSize() -> String {
        var size: Int64 = 0
        
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            for file in files {
                let attributes = try fileManager.attributesOfItem(atPath: file.path)
                size += attributes[.size] as? Int64 ?? 0
            }
        } catch {
            return "0 MB"
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
        
    /// Превращает URL в ключ для хранения
    private func cacheKey(for urlString: String) -> String {
        return urlString.data(using: .utf8)?.base64EncodedString() ?? urlString
    }
    
    /// Возвращает путь к файлу кэша по ключу
    private func fileURL(for key: String) -> URL {
        return cacheDirectory.appendingPathComponent(key)
    }
    
    /// Загружает картинку с диска по ключу
    private func loadFromDisk(key: String) -> UIImage? {
        let url = fileURL(for: key)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    /// Сохраняет картинку на диск в формате
    private func saveToDisk(image: UIImage, key: String) {
        let url = fileURL(for: key)
        guard let data = image.jpegData(compressionQuality: 1.0) else { return }
        try? data.write(to: url)
    }
}
