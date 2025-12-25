//
//  RSSParserService.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import Foundation

/// Универсальный сервис для парсинга XML-структуры RSS-лент
/// Позволяет извлекать заголовки, описание, ссылки и картинки из различных форматов RSS

//   NSObject, Потому что XMLParserDelegate требует этого (это старый API из времён Objective-C)
final class RSSParserService: NSObject, RSSParserProtocol {
    
    // ХРАНИЛИЩЕ ДАННЫХ во время парсинга:
    
    /// Массив, куда складываются ВСЕ распарсенные новости
    /// Когда парсинг закончится, этот массив вернётся наружу
    private var items: [ParsedNewsItem] = []
    
    /// ВРЕМЕННАЯ ПЕРЕМЕННАЯ: текущая новость, которую мы парсим СЕЙЧАС
    private var currentItem: ParsedNewsItem?
    
    /// Имя тега, который парсер читает СЕЙЧАС
    /// Примеры: "title", "link", "description", "item"
    /// Нужно чтобы знать, какое поле заполнять когда парсер найдёт текст
    private var currentElement: String = ""
    
    /// Накопитель ТЕКСТА внутри текущего тега
    /// Пример: для <title>Breaking News</title> здесь будет "Breaking News"
    private var currentText: String = ""
    
    /// Имя источника новостей (например "BBC News", "TechCrunch")
    /// Передаётся извне в метод parse() и привязывается к каждой новости
    private var sourceName: String = ""
    
    
    /// Парсинг RSS-ленты из Data
    func parse(data: Data, sourceName: String) -> [ParsedNewsItem] {
        // Сохраняем имя источника новостей (например, "BBC News"), чтобы знать откуда новость
        self.sourceName = sourceName
        
        // Очищаем массив новостей от предыдущего парсинга (начинаем с чистого листа)
        self.items = []
        
        // Создаём парсер XML, передав ему сырые данные RSS в формате Data
        let parser = XMLParser(data: data)
        
        // Говорим парсеру: "когда будешь читать XML, вызывай МОИ методы (этого класса)"
        parser.delegate = self
        
        // ЗАПУСКАЕМ парсинг! Парсер начинает читать XML и вызывать методы делегата
        // (didStartElement, foundCharacters, didEndElement) - они заполняют self.items
        parser.parse()
        
        // Возвращаем массив новостей, который был заполнен во время парсинга
        return items
    }
    
    /// Извлечь URL картинки из HTML-описания
    /// Этот метод ищет первый тег <img> и вытаскивает URL из атрибута src
    static func extractImageURL(from html: String) -> String? {
        // РЕГУЛЯРНОЕ ВЫРАЖЕНИЕ для поиска <img src="URL">
        // <img - начало тега картинки
        let pattern = #"<img[^>]+src\s*=\s*[\"']([^\"']+)[\"']"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else {
            return nil
        }
        
        // Извлекаем подстроку по найденному диапазону и возвращаем как String
        // html[range] вытаскивает именно URL картинки
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
        
        // ДЕКОДИРУЕМ HTML-сущности (специальные символы в HTML)
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
        // Формат 1: "Mon, 20 Dec 2025 18:03:41 +0100"
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        formatter1.locale = Locale(identifier: "en_US_POSIX")
        if let date = formatter1.date(from: dateString) {
            return date
        }
        
        // Формат 2: "Mon, 20 Dec 2025 18:03:41 GMT"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        formatter2.locale = Locale(identifier: "en_US_POSIX")
        if let date = formatter2.date(from: dateString) {
            return date
        }
        
        // Формат 3: "2025-12-20T18:03:41+0100"
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter3.locale = Locale(identifier: "en_US_POSIX")
        if let date = formatter3.date(from: dateString) {
            return date
        }
        
        return Date()
    }
}

// Эта секция содержит методы, которые XMLParser ВЫЗЫВАЕТ АВТОМАТИЧЕСКИ
// когда читает XML-файл RSS
extension RSSParserService: XMLParserDelegate {
    
    // ========== МЕТОД 1: XMLParser нашёл ОТКРЫВАЮЩИЙ тег ==========
    // Вызывается когда парсер встречает <item>, <title>, <link> и т.д.
    // elementName = имя тега ("item", "title", "link"...)
    // attributeDict = атрибуты тега, например <img src="url"> → ["src": "url"]
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        // Запоминаем имя ТЕКУЩЕГО тега (куда будем сохранять текст потом)
        currentElement = elementName
        
        // Очищаем накопитель текста (начинаем с чистого листа для нового тега)
        currentText = ""
        
        // Если нашли начало новости (<item> или <entry> для Atom-лент)
        if elementName == "item" || elementName == "entry" {
            // Создаём НОВУЮ пустую новость для заполнения
            currentItem = ParsedNewsItem()
        }
        
        // ОСОБЫЙ СЛУЧАЙ: картинки в атрибутах тега (не в содержимом)
        if elementName == "enclosure" || elementName == "media:content" {
            // Если есть атрибут "url" И мы внутри новости (currentItem != nil)
            if let url = attributeDict["url"], currentItem != nil {
                // Сохраняем URL картинки если:
                // 1) type содержит "image" (это точно картинка)
                // 2) ИЛИ у нас ещё нет картинки (берём первую попавшуюся)
                if attributeDict["type"]?.contains("image") == true || currentItem?.imageURL == nil {
                    currentItem?.imageURL = url
                }
            }
        }
    }
    
    // ========== МЕТОД 2: XMLParser нашёл ТЕКСТ внутри тега ==========
    // Вызывается когда парсер встречает текстовое содержимое
    // Пример: в <title>Breaking News</title> вызовется с "Breaking News"
    // ВАЖНО: может вызваться НЕСКОЛЬКО РАЗ для одного тега! Поэтому НАКАПЛИВАЕМ
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Добавляем найденный текст к currentText (накапливаем)
        currentText += string
    }
    
    // ========== МЕТОД 3: XMLParser нашёл ЗАКРЫВАЮЩИЙ тег ==========
    // Вызывается когда парсер встречает </item>, </title>, </link> и т.д.
    // Здесь мы СОХРАНЯЕМ накопленный текст в нужное поле новости
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // Убираем пробелы и переносы строк в начале/конце текста
        let text = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // var item = создаём КОПИЮ currentItem (чтобы можно было менять)
        guard var item = currentItem else { return }
        
        // switch = "в зависимости от имени закрытого тега делаем разное"
        switch elementName {
        // Если закрылся тег <title>...</title>
        case "title":
            // Сохраняем текст как заголовок ТОЛЬКО если он ещё пустой
            // (в RSS может быть несколько title, берём первый)
            if item.title.isEmpty {
                // Очищаем от HTML-тегов и сохраняем
                item.title = RSSParserService.stripHTML(from: text)
            }
        // Если закрылся тег описания (в RSS бывают разные варианты)
        // description = стандартный RSS
        // summary = Atom-ленты
        // content:encoded = полное содержимое статьи
        case "description", "summary", "content:encoded":
            // Сохраняем ТОЛЬКО если описание пустое
            // ИЛИ если это content:encoded (он приоритетнее, переписываем)
            if item.descriptionText.isEmpty || elementName == "content:encoded" {
                // Если ещё нет картинки - пытаемся найти её в HTML описания
                // (многие RSS включают <img> в описание)
                if item.imageURL == nil {
                    item.imageURL = RSSParserService.extractImageURL(from: text)
                }
                // Очищаем HTML-теги и сохраняем чистый текст
                item.descriptionText = RSSParserService.stripHTML(from: text)
            }
            
        // Если закрылся тег <link>...</link>
        case "link":
            // Сохраняем ссылку ТОЛЬКО если она ещё пустая
            if item.link.isEmpty {
                item.link = text
            }
            
        // Если закрылся тег с датой публикации (разные варианты в RSS/Atom)
        // pubDate = стандартный RSS
        // published/updated = Atom-ленты
        case "pubDate", "published", "updated":
            // Сохраняем дату ТОЛЬКО если её ещё нет
            if item.pubDate == nil {
                // Парсим строку с датой в объект Date
                item.pubDate = RSSParserService.parseDate(from: text)
            }
            
        // Если закрылся тег САМОЙ НОВОСТИ </item> или </entry>
        case "item", "entry":
            // Привязываем имя источника к новости
            item.sourceName = sourceName
            
            // Добавляем ГОТОВУЮ новость в массив всех новостей
            items.append(item)
            
            // Очищаем currentItem (больше не внутри тега <item>)
            currentItem = nil
            
        // Для всех остальных тегов (которые нам не интересны)
        default:
            // Ничего не делаем
            break
        }
        
        // Сохраняем изменённую копию обратно в currentItem
        // (т.к. мы работали с var item = копией)
        currentItem = item
    }
}


/// Промежуточная структура для парсинга
/// Это "черновик" новости, который заполняется во время парсинга XML
/// Потом конвертируется в полноценный NewsItem для сохранения в Realm

struct ParsedNewsItem {
    // Заголовок новости, например "Apple выпустила новый iPhone"
    var title: String = ""
    
    // Текстовое описание/содержание новости (без HTML-тегов)
    var descriptionText: String = ""
    
    // URL картинки новости (может не быть, поэтому String?)
    var imageURL: String?
    
    // Ссылка на полную статью в интернете
    var link: String = ""
    
    // Дата публикации новости (опциональная, может не быть)
    var pubDate: Date?
    
    // Название источника ("BBC News", "TechCrunch" и т.д.)
    var sourceName: String = ""
    
    /// Конвертация в Realm-объект NewsItem
    /// Превращает временный ParsedNewsItem в постоянный NewsItem для базы данных
    func toNewsItem() -> NewsItem {
        // Создаём и возвращаем объект NewsItem
        return NewsItem(
            // id: используем ссылку как уникальный идентификатор
            // (две новости не могут иметь одинаковую ссылку)
            id: link,
            
            title: title,
            descriptionText: descriptionText,
            imageURL: imageURL,
            link: link,
            pubDate: pubDate ?? Date(),
            sourceName: sourceName
        )
    }
    
    /// Конвертация в чистую доменную модель
    func toDomainModel() -> NewsArticle {
        NewsArticle(
            id: link,
            title: title,
            description: descriptionText,
            imageURL: imageURL,
            link: link,
            pubDate: pubDate ?? Date(),
            sourceName: sourceName,
            isRead: false
        )
    }
}

