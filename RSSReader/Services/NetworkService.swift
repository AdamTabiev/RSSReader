//
//  NetworkService.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import Foundation

/// Возможные ошибки при работе с сетью
/// Расширенный набор ошибок для детальной диагностики проблем
enum NetworkError: Error, LocalizedError {
    /// Некорректный URL адрес
    case invalidURL
    
    /// Отсутствие данных в ответе
    case noData
    
    /// Ошибка сервера (5xx коды)
    case serverError(Int)
    
    /// Требуется авторизация (401)
    case unauthorized
    
    /// Доступ запрещён (403)
    case forbidden
    
    /// Ресурс не найден (404)
    case notFound
    
    /// Общая ошибка сети (потеря соединения, таймаут и т.д.)
    case networkError(Error)
    
    /// Человекочитаемое описание ошибки на русском языке
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .noData:
            return "Нет данных"
        case .serverError(let code):
            return "Ошибка сервера: \(code)"
        case .unauthorized:
            return "Требуется авторизация"
        case .forbidden:
            return "Доступ запрещён"
        case .notFound:
            return "Ресурс не найден (404)"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

/// Сервис для выполнения HTTP-запросов
/// Поддерживает retry-логику, кэширование, детальные ошибки
final class NetworkService {
    
    static let shared = NetworkService()
    
    /// Настроен с таймаутами и HTTP кэшем
    private let session: URLSession
    
    /// Количество повторных попыток при ошибке
    private let maxRetries = 3
    
    /// Задержка между повторными попытками (в секундах)
    private let retryDelay: UInt64 = 1_000_000_000
    
    /// Настраивает URLSession с:
    /// - Таймаутами (30/60 сек)
    /// - HTTP кэшем (20 MB в памяти, 100 MB на диске)
    /// - Политикой кэширования
    private init() {
        // Создаём конфигурацию URLSession
        let config = URLSessionConfiguration.default
        
        // Таймаут для начала ответа от сервера (30 сек)
        config.timeoutIntervalForRequest = 30
        
        // Таймаут для полной загрузки ресурса (60 сек)
        config.timeoutIntervalForResource = 60
        
        // Настраиваем HTTP кэш для экономии трафика
        // 20 MB в оперативной памяти для быстрого доступа
        // 100 MB на диске для долговременного хранения
        config.urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 100 * 1024 * 1024
        )
        
        // Политика кэширования: соблюдать HTTP заголовки
        // Сервер решает когда кэш устарел через Cache-Control, ETag и т.д.
        // Обеспечивает баланс между свежестью данных и экономией трафика
        config.requestCachePolicy = .useProtocolCachePolicy
        
        // Создаём сессию с настроенной конфигурацией
        self.session = URLSession(configuration: config)
    }
    
    /// Загрузить данные по URL с retry-логикой
    /// Автоматически повторяет запрос при временных ошибках
    ///
    /// - Parameter urlString: URL для загрузки (строка)
    /// - Returns: Загруженные данные
    /// - Throws: NetworkError при неудаче всех попыток
    func fetchData(from urlString: String) async throws -> Data {
        var lastError: Error?
        
        // Пытаемся загрузить данные до maxRetries раз
        for attempt in 0..<maxRetries {
            #if DEBUG
            print("📡 NetworkService: Attempt \(attempt + 1)/\(maxRetries) for \(urlString)")
            #endif
            
            do {
                // Вызываем приватный метод для одной попытки
                let data = try await fetchDataSingleAttempt(from: urlString)
                
                #if DEBUG
                print("✅ NetworkService: Success on attempt \(attempt + 1)")
                #endif
                
                return data
            } catch {
                lastError = error
                
                #if DEBUG
                print("⚠️ NetworkService: Failed attempt \(attempt + 1): \(error)")
                #endif
                
                // Если это не последняя попытка - ждём перед retry
                if attempt < maxRetries - 1 {
                    #if DEBUG
                    print("⏱️ NetworkService: Retrying in 1 sec...")
                    #endif
                    
                    try? await Task.sleep(nanoseconds: retryDelay)
                }
            }
        }
        
        // Все попытки исчерпаны - выбрасываем последнюю ошибку
        #if DEBUG
        print("❌ NetworkService: All attempts failed for \(urlString)")
        #endif
        
        throw lastError ?? NetworkError.networkError(NSError(domain: "Unknown", code: -1))
    }
    
    /// Одна попытка загрузки данных (без retry)
    /// Приватный метод, используется внутри fetchData с retry-логикой
    ///
    /// - Parameter urlString: URL для загрузки
    /// - Returns: Загруженные данные
    /// - Throws: NetworkError при любой ошибке
    private func fetchDataSingleAttempt(from urlString: String) async throws -> Data {
        // Проверяем валидность URL
        guard let url = URL(string: urlString) else {
            #if DEBUG
            print("❌ NetworkService: Invalid URL - \(urlString)")
            #endif
            throw NetworkError.invalidURL
        }
        
        do {
            // Загружаем данные асинхронно
            let (data, response) = try await session.data(from: url)
            
            // Проверяем что response - это HTTP ответ
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            
            #if DEBUG
            print("📊 NetworkService: HTTP \(httpResponse.statusCode) from \(urlString)")
            #endif
            
            // Обрабатываем разные статус коды детально
            switch httpResponse.statusCode {
            case 200...299:
                // Успех! Возвращаем данные
                return data
                
            case 401:
                // Требуется авторизация
                throw NetworkError.unauthorized
                
            case 403:
                // Доступ запрещён
                throw NetworkError.forbidden
                
            case 404:
                // Ресурс не найден
                throw NetworkError.notFound
                
            case 500...599:
                // Ошибка сервера
                throw NetworkError.serverError(httpResponse.statusCode)
                
            default:
                // Другие коды (клиентские ошибки 4xx и т.д.)
                throw NetworkError.noData
            }
            
        } catch let error as NetworkError {
            // Если это уже наша ошибка - пробрасываем как есть
            throw error
        } catch {
            // Любая другая ошибка (сеть, таймаут и т.д.)
            #if DEBUG
            print("❌ NetworkService: Network error - \(error.localizedDescription)")
            #endif
            throw NetworkError.networkError(error)
        }
    }
    
    /// Проверить, является ли URL валидным RSS/Atom фидом
    /// Использует XMLParser для точной валидации
    /// Более надёжно чем простой поиск строк в контенте
    ///
    /// - Parameter urlString: URL для проверки
    /// - Returns: true если это RSS/Atom фид, false в противном случае
    func validateRSSURL(_ urlString: String) async -> Bool {
        #if DEBUG
        print("🔍 NetworkService: Validating RSS URL - \(urlString)")
        #endif
        
        do {
            // Пытаемся загрузить данные
            let data = try await fetchData(from: urlString)
            
            // Создаём XML парсер для точной валидации
            let parser = XMLParser(data: data)
            let delegate = RSSValidationDelegate()
            parser.delegate = delegate
            
            // Парсим (остановится при нахождении rss/feed тега)
            parser.parse()
            
            #if DEBUG
            if delegate.isValidRSS {
                print("✅ NetworkService: Valid RSS/Atom feed")
            } else {
                print("❌ NetworkService: Not a valid RSS/Atom feed")
            }
            #endif
            
            return delegate.isValidRSS
            
        } catch {
            #if DEBUG
            print("❌ NetworkService: Validation failed - \(error)")
            #endif
            return false
        }
    }
}

/// Делегат для валидации RSS/Atom фидов через XMLParser
/// Используется только для проверки наличия корневых тегов RSS
private class RSSValidationDelegate: NSObject, XMLParserDelegate {
    /// Флаг - найден ли валидный RSS/Atom тег
    var isValidRSS = false
    
    /// Вызывается при встрече открывающего тега
    /// Проверяем является ли это корневым тегом RSS или Atom
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        // Проверяем корневые теги для RSS 2.0 и Atom
        if elementName == "rss" || elementName == "feed" {
            isValidRSS = true
            // Нашли что искали - прерываем парсинг
            // Не нужно парсить весь файл целиком
            parser.abortParsing()
        }
    }
}
