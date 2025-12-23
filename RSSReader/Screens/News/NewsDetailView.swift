//
//  NewsDetailView.swift
//  RSSReader
//
//  Created by Адам Табиев on 18.12.2025.
//

import SwiftUI
import WebKit

/// Экран детального просмотра новости через WebView
/// Открывает оригинальную статью по ссылке из RSS
struct NewsDetailView: View {
    
    let urlString: String
    
    @State private var isLoading: Bool = true
    
    var body: some View {
        ZStack {
            WebView(urlString: urlString, isLoading: $isLoading)
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.2)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - WebView

/// UIViewRepresentable обёртка для WKWebView
struct WebView: UIViewRepresentable {
    
    let urlString: String
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: urlString) else { return }
        
        // Загружаем только если URL изменился
        if webView.url?.absoluteString != urlString {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        NewsDetailView(urlString: "https://www.apple.com")
    }
}
