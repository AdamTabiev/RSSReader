//
//  SettingsRowView.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import SwiftUI

// MARK: - Settings Row View

/// Ячейка в меню настроек
struct SettingsRowView: View {
    
    let title: String
    let icon: String
    let iconColor: Color
    var value: String? = nil
    
    var body: some View {
        HStack {
            // Иконка
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(iconColor)
                .cornerRadius(8)
            
            // Заголовок
            Text(title)
                .font(.system(size: 17))
                .foregroundStyle(.primary)
            
            Spacer()
            
            // Значение (если есть)
            if let value = value {
                Text(value)
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
            }
            
            // Стрелочка
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews

#Preview {
    List {
        SettingsRowView(title: "Источники", icon: "list.bullet", iconColor: .blue)
        SettingsRowView(title: "Частота обновления", icon: "timer", iconColor: .orange, value: "30 мин")
    }
}
