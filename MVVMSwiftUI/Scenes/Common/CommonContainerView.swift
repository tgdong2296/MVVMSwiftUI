//
//  CommonContainerView.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 4/3/26.
//

import SwiftUI

struct CommonContainerView<Content: View, Loading: View, ErrorContent: View>: View {
    
    let viewState: ViewState
    let content: Content
    let loadingView: Loading
    let errorView: (String) -> ErrorContent
    var onRetry: (() -> Void)?
    
    var body: some View {
        ZStack {
            content
            
            switch viewState {
            case .loading:
                loadingView
            case .error(let messages):
                errorView(messages.joined())
            case .success, .indie:
                EmptyView()
            }
        }
    }
}

// MARK: - Default Loading + Default Error

extension CommonContainerView where Loading == CommonLoadingView, ErrorContent == CommonErrorView {
    
    init(
        viewState: ViewState,
        onRetry: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.viewState = viewState
        self.content = content()
        self.loadingView = CommonLoadingView()
        self.onRetry = onRetry
        self.errorView = { message in
            CommonErrorView(errorMessage: message, onRetry: onRetry)
        }
    }
}

// MARK: - Custom Loading + Default Error

extension CommonContainerView where ErrorContent == CommonErrorView {
    
    init(
        viewState: ViewState,
        onRetry: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder loadingView: () -> Loading
    ) {
        self.viewState = viewState
        self.content = content()
        self.loadingView = loadingView()
        self.onRetry = onRetry
        self.errorView = { message in
            CommonErrorView(errorMessage: message, onRetry: onRetry)
        }
    }
}

// MARK: - Default Loading + Custom Error

extension CommonContainerView where Loading == CommonLoadingView {
    
    init(
        viewState: ViewState,
        @ViewBuilder content: () -> Content,
        @ViewBuilder errorView: @escaping (String) -> ErrorContent
    ) {
        self.viewState = viewState
        self.content = content()
        self.loadingView = CommonLoadingView()
        self.onRetry = nil
        self.errorView = errorView
    }
}

// MARK: - Custom Loading + Custom Error

extension CommonContainerView {
    
    init(
        viewState: ViewState,
        @ViewBuilder content: () -> Content,
        @ViewBuilder loadingView: () -> Loading,
        @ViewBuilder errorView: @escaping (String) -> ErrorContent
    ) {
        self.viewState = viewState
        self.content = content()
        self.loadingView = loadingView()
        self.onRetry = nil
        self.errorView = errorView
    }
}
