//
//  UserDefaultsServiceType.swift
//  PomodoroTimer
//
//  Created by Giang Dong Trinh on 23/2/26.
//

import Foundation

/// Protocol defining the interface for UserDefaults data storage operations.
/// All key-value persistence via UserDefaults should go through this service.
nonisolated protocol UserDefaultsServiceType {
    
    // MARK: - Getters
    
    /// Retrieve a Bool value for the given key.
    func bool(forKey key: String) -> Bool
    
    /// Retrieve an Int value for the given key.
    func integer(forKey key: String) -> Int
    
    /// Retrieve a Double value for the given key.
    func double(forKey key: String) -> Double
    
    /// Retrieve a String value for the given key.
    func string(forKey key: String) -> String?
    
    /// Retrieve a Data value for the given key.
    func data(forKey key: String) -> Data?
    
    /// Retrieve any object for the given key.
    func object(forKey key: String) -> Any?
    
    // MARK: - Setters
    
    /// Store a Bool value for the given key.
    func set(_ value: Bool, forKey key: String)
    
    /// Store an Int value for the given key.
    func set(_ value: Int, forKey key: String)
    
    /// Store a Double value for the given key.
    func set(_ value: Double, forKey key: String)
    
    /// Store a String value for the given key.
    func set(_ value: String?, forKey key: String)
    
    /// Store a Data value for the given key.
    func set(_ value: Data?, forKey key: String)
    
    /// Store any object for the given key.
    func set(_ value: Any?, forKey key: String)
    
    // MARK: - Removal
    
    /// Remove the value associated with the given key.
    func removeObject(forKey key: String)
    
    /// Check whether a value exists for the given key.
    func hasValue(forKey key: String) -> Bool
}
