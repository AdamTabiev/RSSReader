//
//  CachedImageView.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import SwiftUI

// MARK: - Cached Image View

/// Компонент для отображения изображений с поддержкой кэширования
/// Сначала проверяет наличие картинки в локальном кэше, затем загружает из сети
struct CachedImageView: View {
    
    /// URL изображения для загрузки
    let urlString: String?
    /// Желаемый размер отображения
    let size: CGSize
    
    /// Загруженное изображение
    @State private var image: UIImage?
    /// Флаг процесса загрузки
    @State private var isLoading: Bool = true
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .clipped()
            } else if isLoading {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: size.width, height: size.height)
                    .overlay {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
            } else {
                // Placeholder
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: size.width, height: size.height)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
            }
        }
        .cornerRadius(8)
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let urlString = urlString, !urlString.isEmpty else {
            isLoading = false
            return
        }
        
        if let loadedImage = await ImageCacheService.shared.loadImage(from: urlString) {
            await MainActor.run {
                self.image = loadedImage
                self.isLoading = false
            }
        } else {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}

// MARK: - Previews

#Preview {
    VStack {
        CachedImageView(
            urlString: "https://example.com/image.jpg",
            size: CGSize(width: 80, height: 80)
        )
    }
}
