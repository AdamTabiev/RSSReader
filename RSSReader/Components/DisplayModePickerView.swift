//
//  DisplayModePickerView.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import SwiftUI

/// Переключатель режимов отображения новостей (обычный / расширенный)
struct DisplayModePickerView: View {
    
    /// Текущий режим отображения
    @Binding var displayMode: DisplayMode
    
    var body: some View {
        Picker("Режим", selection: $displayMode) {
            Text("•").tag(DisplayMode.regular)
            Text("•••").tag(DisplayMode.extended)
        }
        .pickerStyle(.segmented)
        .frame(width: 100)
    }
}

#Preview {
    struct PreviewContainer: View {
        @State var displayMode: DisplayMode = .regular
        var body: some View {
            DisplayModePickerView(displayMode: $displayMode)
        }
    }
    return PreviewContainer()
        .padding()
}
