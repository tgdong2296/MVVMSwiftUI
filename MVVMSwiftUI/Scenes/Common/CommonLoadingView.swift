//
//  CommonLoadingView.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 4/3/26.
//

import SwiftUI

struct CommonLoadingView: View {
    
    @Environment(ThemeStore.self)
    private var themeStore
    
    var body: some View {
        ZStack {
            themeStore.overlayColor
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                themeStore.surfaceColor
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(1.2)
            }
            .cornerRadius(16)
            .frame(width: 80, height: 80)
        }
    }
}

#Preview {
    NavigationStack {
        HStack {}
            .frame(width: .infinity, height: .infinity)
            .background(Color.white)
            .overlay(CommonLoadingView())
    }
}
