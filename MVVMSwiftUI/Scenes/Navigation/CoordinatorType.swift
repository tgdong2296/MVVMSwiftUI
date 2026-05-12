//
//  CoordinatorType.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 3/26/26.
//

import SwiftUI

protocol CoordinatorType: Observable, AnyObject {
    associatedtype CoordinatorRoutes: Route
    associatedtype CoordinatorView: View
    associatedtype RootView: View
    
    var path: [CoordinatorRoutes] { get set }
    
    @ViewBuilder
    func redirect(_ path: CoordinatorRoutes) -> CoordinatorView
    
    @ViewBuilder
    func rootView() -> RootView
}
