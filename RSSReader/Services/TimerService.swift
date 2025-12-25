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
    
    /// Таймер для периодического обновления
    private var timer: Timer?
    
    /// Колбэк, который вызывается при каждом срабатывании таймера
    var onTimerTick: (() -> Void)?
        
    init() {
        startTimer()
        setupUserDefaultsObserver()
    }
    
    deinit {
        stopTimer()
        NotificationCenter.default.removeObserver(self)
    }
        
    /// Подписывается на уведомления об изменении UserDefaults
    private func setupUserDefaultsObserver() {
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.restartTimer()
        }
    }
        
    /// Запускает таймер на основе интервала из настроек
    func startTimer() {
        stopTimer()
        
        let intervalMinutes = UserDefaults.standard.integer(forKey: "refreshInterval")
        let intervalSeconds = TimeInterval(intervalMinutes == 0 ? 30 * 60 : intervalMinutes * 60)
        
        timer = Timer.scheduledTimer(withTimeInterval: intervalSeconds, repeats: true) { [weak self] _ in
            self?.onTimerTick?()
        }
    }
    
    /// Останавливает таймер
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Перезапускает таймер с новым интервалом
    func restartTimer() {
        startTimer()
    }
}
