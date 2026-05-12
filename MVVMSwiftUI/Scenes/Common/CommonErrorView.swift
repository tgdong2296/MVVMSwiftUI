//
//  CommonErrorView.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 4/3/26.
//

import SwiftUI

struct CommonErrorView: View {
    
    let errorMessage: String
    
    var onRetry: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Error")
                .font(.title)
            
            Text(errorMessage)
                .multilineTextAlignment(.center)
                .padding()
            
            if let retryAction = onRetry {
                Button(action: retryAction) {
                    Text("Retry")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        HStack {}
            .frame(width: .infinity, height: .infinity)
            .background(Color.white)
            .overlay(CommonErrorView(errorMessage: "Connection Error", onRetry: { }))
    }
}
