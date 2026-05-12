//
//  FirebaseService.swift
//  PomodoroTimer
//
//  Created by Giang Dong Trinh on 9/3/26.
//

import Foundation
import FactoryKit

final class FirebaseService: FirebaseServiceType {
    
    func configure() {
        // Detail implement
    }
}

// MARK: - Factory Registration
extension Container {
    var firebaseService: Factory<FirebaseServiceType> {
        Factory(self) { @MainActor in FirebaseService() }
            .singleton
    }
}
