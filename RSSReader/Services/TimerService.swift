//
//  TimerService.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import Foundation
import SwiftUI
import Combine

/// Сервис для автоматического обновления новостей по таймеру.
final class TimerService: ObservableObject {
    
    private var timer: Timer?
    
    /// Колбэк, который вызывается при каждом срабатывании таймера.
    /// () -> Void = функция без параметров, ничего не возвращает.
    var onTimerTick: (() -> Void)?
        
    init() {
        startTimer()
        setupUserDefaultsObserver()
    }
    
    deinit {
        stopTimer()
        NotificationCenter.default.removeObserver(self)
    }
        
    /// Подписывается на уведомления об изменении UserDefaults.
    /// Когда пользователь меняет интервал обновления — таймер перезапускается.
    private func setupUserDefaultsObserver() {
        // NotificationCenter = "доска объявлений" в iOS для обмена сообщениями
        NotificationCenter.default.addObserver(
            // Какое уведомление слушаем: "настройки UserDefaults изменились"
            forName: UserDefaults.didChangeNotification,
            // От кого слушаем: nil = от любого источника
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // [weak self] = слабая ссылка, чтобы избежать утечки памяти
            // _ = содержимое уведомления нам не нужно
            // self? = если объект ещё существует, перезапустить таймер
            self?.restartTimer()
        }
    }
        
    /// Запускает таймер на основе интервала из настроек.
    /// Сначала останавливает предыдущий таймер, затем создаёт новый.
    func startTimer() {
        // Останавливаем старый таймер (если был)
        stopTimer()
        
        // Читаем интервал из UserDefaults (в минутах)
        // integer(forKey:) вернёт 0, если ключ не найден
        let intervalMinutes = UserDefaults.standard.integer(forKey: "refreshInterval")
        
        // Переводим минуты в секунды. Если 0 — используем 30 минут по умолчанию.
        // TimeInterval = Double (секунды)
        let intervalSeconds = TimeInterval(intervalMinutes == 0 ? 30 * 60 : intervalMinutes * 60)
                
        // Создаём и запускаем таймер через нативный Timer:
        timer = Timer.scheduledTimer(
            withTimeInterval: intervalSeconds,
            repeats: true
        ) { [weak self] _ in
            // Этот код выполняется при каждом "тике" таймера
            // Вызываем колбэк, если он установлен (syncAllSources)
            self?.onTimerTick?()
        }
        
        // Добавляем таймер в RunLoop с режимом .common
        // Режим .common работает даже при скролле
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Перезапускает таймер с новым интервалом.
    /// Вызывается автоматически при изменении настроек.
    func restartTimer() {
        // startTimer() сначала остановит старый, затем создаст новый
        startTimer()
    }
}
