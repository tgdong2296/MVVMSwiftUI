//
//  EmailRule.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 4/1/26.
//

import Foundation

struct EmailRule: ValidationRule {
    
    let message: String
    
    func validate(value: String) -> String? {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        if !predicate.evaluate(with: value) {
            return message
        }
        return nil
    }
}

extension ValidationRule where Self == EmailRule {
    
    static func isEmail(message: String = "Invalid email address") -> EmailRule {
        EmailRule(message: message)
    }
}
