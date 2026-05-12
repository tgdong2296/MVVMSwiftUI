//
//  Environments.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 3/25/26.
//

import Foundation

enum Environments {
    
    static var isDEV: Bool {
        guard let stringValue = getEnvironmentValue(forKey: "IS_DEV") else {
            return false
        }
        return stringValue == "YES"
    }
    
    static var supportEmail: String {
        getEnvironmentValue(forKey: "SUPPORT_EMAIL") ?? "support@pomodorotimer.app"
    }
    
    static var appStoreId: String {
        getEnvironmentValue(forKey: "APP_STORE_ID") ?? ""
    }
    
    static var termsOfUseURL: String {
        getEnvironmentValue(forKey: "TERMS_OF_USE_URL") ?? ""
    }
    
    static var privacyPolicyURL: String {
        getEnvironmentValue(forKey: "PRIVACY_POLICY_URL") ?? ""
    }
    
    static var baseURL: String {
        getEnvironmentValue(forKey: "BASE_URL") ?? ""
    }
    
    static func getEnvironmentValue(forKey key: String) -> String? {
        guard let value = Bundle.main.infoDictionary?[key] as? String, !value.isEmpty else {
            return nil
        }
        return value
    }
}
