//
//  UserDefaultsService.swift
//  PomodoroTimer
//
//  Created by Giang Dong Trinh on 23/2/26.
//

import Foundation
import FactoryKit

/// Concrete implementation of `UserDefaultsServiceType` backed by `UserDefaults.standard`.
nonisolated struct UserDefaultsService: UserDefaultsServiceType {
    
    // MARK: - Private Properties
    private let defaults: UserDefaults
    
    // MARK: - Initializer
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // MARK: - Getters
    
    func bool(forKey key: String) -> Bool {
        defaults.bool(forKey: key)
    }
    
    func integer(forKey key: String) -> Int {
        defaults.integer(forKey: key)
    }
    
    func double(forKey key: String) -> Double {
        defaults.double(forKey: key)
    }
    
    func string(forKey key: String) -> String? {
        defaults.string(forKey: key)
    }
    
    func data(forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }
    
    func object(forKey key: String) -> Any? {
        defaults.object(forKey: key)
    }
    
    // MARK: - Setters
    
    func set(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func set(_ value: Int, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func set(_ value: Double, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func set(_ value: String?, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func set(_ value: Data?, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func set(_ value: Any?, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    // MARK: - Removal
    
    func removeObject(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
    
    func hasValue(forKey key: String) -> Bool {
        defaults.object(forKey: key) != nil
    }
}

// MARK: - Factory Registration
extension Container {
    var userDefaultsService: Factory<UserDefaultsServiceType> {
        Factory(self) {
            UserDefaultsService()
        }
        .singleton
    }
}
