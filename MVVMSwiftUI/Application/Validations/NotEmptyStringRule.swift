//
//  NotEmptyStringRule.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 4/1/26.
//

import Foundation

struct NotEmptyStringRule: ValidationRule {
    
    let message: String
    
    func validate(value: String) -> String? {
        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return message
        }
        return nil
    }
}

extension ValidationRule where Self == NotEmptyStringRule {
    
    static func isNotEmpty(message: String) -> NotEmptyStringRule {
        NotEmptyStringRule(message: message)
    }
}
