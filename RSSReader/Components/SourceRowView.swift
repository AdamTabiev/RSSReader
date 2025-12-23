//
//  SourceRowView.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import SwiftUI

// MARK: - Source Row View

/// Ячейка источника в списке источников
struct SourceRowView: View {
    
    let name: String
    let url: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 17, weight: .medium))
                
                Text(url)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .tint(.blue)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        SourceRowView(
            name: "Ведомости",
            url: "https://vedomosti.ru/rss",
            isEnabled: .constant(true)
        )
    }
}
