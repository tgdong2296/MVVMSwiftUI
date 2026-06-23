//
//  AppFlow.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 3/26/26.
//

enum AppFlow: Identifiable {
    case loading
    case notAuthenticated
    case authenticated
    
    var id: AppFlow { self }
}
