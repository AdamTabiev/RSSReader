//
//  RSSParserService.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import Foundation

// MARK: - RSS Parser Service

/// Универсальный сервис для парсинга XML-структуры RSS-лент
/// Позволяет извлекать заголовки, описание, ссылки и картинки из различных форматов RSS
final class RSSParserService: NSObject {
    
    /// Список распарсенных элементов новостей
    private var items: [ParsedNewsItem] = []
    /// Текущий элемент, который находится в процессе парсинга
    private var currentItem: ParsedNewsItem?
    /// Название текущего обрабатываемого XML-тега
    private var currentElement: String = ""
    /// Текстовое содержимое текущего тега
    private var currentText: String = ""
    /// Название источника новости для привязки к элементу
    private var sourceName: String = ""
    
    // MARK: - Public Methods
    
    /// Парсинг RSS-ленты из Data
    func parse(data: Data, sourceName: String) -> [ParsedNewsItem] {
        self.sourceName = sourceName
        self.items = []
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        
        return items
    }
    
    /// Извлечь URL картинки из HTML-описания
    static func extractImageURL(from html: String) -> String? {
        // Ищем тег <img src="...">
        let pattern = #"<img[^>]+src\s*=\s*[\"']([^\"']+)[\"']"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else {
            return nil
        }
        
        return String(html[range])
    }
    
    /// Очистить HTML-теги из текста
    static func stripHTML(from html: String) -> String {
        let pattern = "<[^>]+>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return html
        }
        
        let range = NSRange(html.startIndex..., in: html)
        var result = regex.stringByReplacingMatches(in: html, range: range, withTemplate: "")
        
        // Декодируем HTML-сущности
        result = result.replacingOccurrences(of: "&nbsp;", with: " ")
        result = result.replacingOccurrences(of: "&amp;", with: "&")
        result = result.replacingOccurrences(of: "&lt;", with: "<")
        result = result.replacingOccurrences(of: "&gt;", with: ">")
        result = result.replacingOccurrences(of: "&quot;", with: "\"")
        result = result.replacingOccurrences(of: "&#39;", with: "'")
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Парсинг даты из RSS
    static func parseDate(from dateString: String) -> Date {
        let formatters: [DateFormatter] = [
            {
                let f = DateFormatter()
                f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
                f.locale = Locale(identifier: "en_US_POSIX")
                return f
            }(),
            {
                let f = DateFormatter()
                f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
                f.locale = Locale(identifier: "en_US_POSIX")
                return f
            }(),
            {
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                f.locale = Locale(identifier: "en_US_POSIX")
                return f
            }()
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return Date()
    }
}

// MARK: - XMLParser Delegate

extension RSSParserService: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        currentText = ""
        
        if elementName == "item" || elementName == "entry" {
            currentItem = ParsedNewsItem()
        }
        
        // Проверяем enclosure для картинки
        if elementName == "enclosure" || elementName == "media:content" {
            if let url = attributeDict["url"], currentItem != nil {
                if attributeDict["type"]?.contains("image") == true || currentItem?.imageURL == nil {
                    currentItem?.imageURL = url
                }
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let text = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard var item = currentItem else { return }
        
        switch elementName {
        case "title":
            if item.title.isEmpty {
                item.title = RSSParserService.stripHTML(from: text)
            }
        case "description", "summary", "content:encoded":
            if item.descriptionText.isEmpty || elementName == "content:encoded" {
                // Извлекаем картинку из HTML если её ещё нет
                if item.imageURL == nil {
                    item.imageURL = RSSParserService.extractImageURL(from: text)
                }
                item.descriptionText = RSSParserService.stripHTML(from: text)
            }
        case "link":
            if item.link.isEmpty {
                item.link = text
            }
        case "pubDate", "published", "updated":
            if item.pubDate == nil {
                item.pubDate = RSSParserService.parseDate(from: text)
            }
        case "item", "entry":
            item.sourceName = sourceName
            items.append(item)
            currentItem = nil
        default:
            break
        }
        
        currentItem = item
    }
}

// MARK: - Parsed News Item

/// Промежуточная структура для парсинга
struct ParsedNewsItem {
    var title: String = ""
    var descriptionText: String = ""
    var imageURL: String?
    var link: String = ""
    var pubDate: Date?
    var sourceName: String = ""
    
    /// Конвертация в Realm-объект NewsItem
    func toNewsItem() -> NewsItem {
        return NewsItem(
            id: link, // Используем ссылку как уникальный ID
            title: title,
            descriptionText: descriptionText,
            imageURL: imageURL,
            link: link,
            pubDate: pubDate ?? Date(),
            sourceName: sourceName
        )
    }
}
