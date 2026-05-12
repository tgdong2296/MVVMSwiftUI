//
//  PasswordRule.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 4/1/26.
//

import Foundation

struct PasswordRule: ValidationRule {
    
    let minLength: Int
    let requiresUppercase: Bool
    let requiresLowercase: Bool
    let requiresDigit: Bool
    let requiresSpecialCharacter: Bool
    let message: String?
    
    func validate(value: String) -> String? {
        var errors: [String] = []
        
        if value.count < minLength {
            errors.append("Password must be at least \(minLength) characters")
        }
        
        if requiresUppercase && value.range(of: "[A-Z]", options: .regularExpression) == nil {
            errors.append("Password must contain at least one uppercase letter")
        }
        
        if requiresLowercase && value.range(of: "[a-z]", options: .regularExpression) == nil {
            errors.append("Password must contain at least one lowercase letter")
        }
        
        if requiresDigit && value.range(of: "[0-9]", options: .regularExpression) == nil {
            errors.append("Password must contain at least one digit")
        }
        
        if requiresSpecialCharacter && value.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) == nil {
            errors.append("Password must contain at least one special character")
        }
        
        if !errors.isEmpty {
            return message ?? errors.joined(separator: ". ")
        }
        
        return nil
    }
}

extension ValidationRule where Self == PasswordRule {
    
    static func isPassword(
        minLength: Int = 8,
        requiresUppercase: Bool = true,
        requiresLowercase: Bool = true,
        requiresDigit: Bool = true,
        requiresSpecialCharacter: Bool = false,
        message: String? = nil
    ) -> PasswordRule {
        PasswordRule(
            minLength: minLength,
            requiresUppercase: requiresUppercase,
            requiresLowercase: requiresLowercase,
            requiresDigit: requiresDigit,
            requiresSpecialCharacter: requiresSpecialCharacter,
            message: message
        )
    }
}
