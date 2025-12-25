//
//  SourcesListView.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import SwiftUI

/// Экран управления источниками RSS
struct SourcesListView: View {
    
    @StateObject private var viewModel: SourcesListViewModel
    
    /// Состояние для формы добавления
    @State private var showingAddSource = false
    @State private var newSourceName = ""
    @State private var newSourceURL = ""
    
    init(viewModel: SourcesListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        List {
            ForEach(viewModel.sources) { source in
                SourceRowView(
                    name: source.name,
                    url: source.url,
                    isEnabled: Binding(
                        get: { source.isEnabled },
                        set: { _ in viewModel.toggleSource(source) }
                    )
                )
            }
            .onDelete(perform: viewModel.deleteSource)
        }
        .navigationTitle("Источники")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddSource = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                }
            }
        }
        // Форма добавления нового источника
        .sheet(isPresented: $showingAddSource) {
            NavigationStack {
                Form {
                    Section(header: Text("Данные источника")) {
                        TextField("Название (например, Tech News)", text: $newSourceName)
                        TextField("URL (https://...)", text: $newSourceURL)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    if let error = viewModel.errorMessage {
                        Section {
                            Text(error)
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }
                }
                .navigationTitle("Новый источник")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Отмена") {
                            showingAddSource = false
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Button("Добавить") {
                                Task {
                                    let success = await viewModel.addSource(name: newSourceName, url: newSourceURL)
                                    if success {
                                        newSourceName = ""
                                        newSourceURL = ""
                                        showingAddSource = false
                                    }
                                }
                            }
                            .disabled(newSourceName.isEmpty || newSourceURL.isEmpty)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        SourcesListView(viewModel: DependencyContainer().makeSourcesListViewModel())
    }
}
