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
    
    let source: RSSSource
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(source.name)
                    .font(.system(size: 17, weight: .medium))
                
                Text(source.url)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { source.isEnabled },
                set: { onToggle($0) }
            ))
            .labelsHidden()
            .tint(.blue)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews

#Preview {
    let source = RSSSource(name: "Ведомости", url: "https://vedomosti.ru/rss")
    return List {
        SourceRowView(source: source, onToggle: { _ in })
    }
}
