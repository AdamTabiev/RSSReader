//
//  SettingsButtonView.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import SwiftUI

/// Кнопка перехода к экрану настроек
struct SettingsButtonView: View {
    
    /// Действие при нажатии
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "gearshape")
                .font(.system(size: 16, weight: .medium))
        }
    }
}

#Preview {
    SettingsButtonView(action: {})
        .padding()
}
