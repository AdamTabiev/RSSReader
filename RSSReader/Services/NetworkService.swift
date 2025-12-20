//
//  NetworkService.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import Foundation

// MARK: - Network Error

/// Возможные ошибки при работе с сетью
enum NetworkError: Error, LocalizedError {
    /// Некорректный URL адрес
    case invalidURL
    /// Отсутствие данных в ответе
    case noData
    /// Ошибка при парсинге данных
    case decodingError
    /// Общая ошибка сети
    case networkError(Error)
    
    /// Описание ошибки на русском языке
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .noData:
            return "Нет данных"
        case .decodingError:
            return "Ошибка декодирования"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - Network Service

/// Сервис для выполнения HTTP-запросов
/// Используется для загрузки RSS-лент и проверки их валидности
final class NetworkService {
    
    /// Сессия для выполнения запросов
    private let session: URLSession
    
    /// Инициализация с базовой конфигурацией таймаутов
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    /// Загрузить данные по URL
    func fetchData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.noData
            }
            
            return data
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
    
    /// Проверить, является ли URL валидным RSS
    func validateRSSURL(_ urlString: String) async -> Bool {
        do {
            let data = try await fetchData(from: urlString)
            let dataString = String(data: data, encoding: .utf8) ?? ""
            // Проверяем наличие RSS-тегов
            return dataString.contains("<rss") || dataString.contains("<feed") || dataString.contains("<channel")
        } catch {
            return false
        }
    }
}
