//
//  RefreshButtonView.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import SwiftUI

/// Кнопка обновления ленты новостей
struct RefreshButtonView: View {
    
    /// Состояние загрузки
    let isLoading: Bool
    /// Действие при нажатии
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .medium))
            }
        }
        .disabled(isLoading)
    }
}

#Preview {
    HStack {
        RefreshButtonView(isLoading: false, action: {})
        RefreshButtonView(isLoading: true, action: {})
    }
    .padding()
}
