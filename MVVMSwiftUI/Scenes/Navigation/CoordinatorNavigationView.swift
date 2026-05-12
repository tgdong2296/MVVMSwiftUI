//
//  CoordinatorNavigationView.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 3/26/26.
//

import SwiftUI

struct CoordinatorNavigationView<Coordinator: CoordinatorType>: View {
    @Bindable var coordinator: Coordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.rootView()
                .navigationDestination(for: Coordinator.CoordinatorRoutes.self) { step in
                    coordinator.redirect(step)
                }
        }
        .environment(coordinator)
    }
}
