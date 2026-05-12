//
//  ValidationModifier.swift
//  VMPatternSwiftUI
//
//  Created by Giang Dong Trinh on 2/4/26.
//

import SwiftUI

// MARK: - Validation Modifier
private struct ValidationModifier: ViewModifier {
    
    let state: ValidationState
    
    @Environment(ThemeStore.self)
    private var themeStore
    
    func body(content: Content) -> some View {
        VStack(alignment: .trailing) {
            content
                .padding(.bottom, 4)
            
            VStack {
                if case .invalid(let messages) = state {
                    ForEach(messages, id: \.self) { message in
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(themeStore.errorColor)
                    }
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }.frame(maxWidth: .infinity, minHeight: 16, alignment: .trailing)
        }
        .animation(.easeInOut(duration: 0.2), value: state)
    }
}

extension View {
    
    func validation(_ state: ValidationState) -> some View {
        modifier(ValidationModifier(state: state))
    }
}
