//
//  PasswordRuleTests.swift
//  MVVMSwiftUITests
//

import Testing
@testable import MVVMSwiftUI

@Suite("PasswordRule")
struct PasswordRuleTests {

    // MARK: - Length

    @Test("Password meeting min length passes")
    func meetsMinLength() {
        let rule = PasswordRule.isPassword(
            minLength: 8,
            requiresUppercase: false,
            requiresLowercase: false,
            requiresDigit: false
        )
        #expect(rule.validate(value: "abcdefgh") == nil)
    }

    @Test("Password below min length fails")
    func belowMinLength() {
        let rule = PasswordRule.isPassword(
            minLength: 8,
            requiresUppercase: false,
            requiresLowercase: false,
            requiresDigit: false
        )
        let error = rule.validate(value: "abc")
        #expect(error?.contains("at least 8 characters") == true)
    }

    // MARK: - Uppercase

    @Test("Password with uppercase passes when required")
    func uppercasePresent() {
        let rule = PasswordRule.isPassword(
            requiresUppercase: true,
            requiresLowercase: false,
            requiresDigit: false
        )
        #expect(rule.validate(value: "Password") == nil)
    }

    @Test("Password without uppercase fails when required")
    func uppercaseMissing() {
        let rule = PasswordRule.isPassword(
            requiresUppercase: true,
            requiresLowercase: false,
            requiresDigit: false
        )
        let error = rule.validate(value: "password")
        #expect(error?.contains("uppercase") == true)
    }

    // MARK: - Lowercase

    @Test("Password with lowercase passes when required")
    func lowercasePresent() {
        let rule = PasswordRule.isPassword(
            requiresUppercase: false,
            requiresLowercase: true,
            requiresDigit: false
        )
        #expect(rule.validate(value: "password") == nil)
    }

    @Test("Password without lowercase fails when required")
    func lowercaseMissing() {
        let rule = PasswordRule.isPassword(
            requiresUppercase: false,
            requiresLowercase: true,
            requiresDigit: false
        )
        let error = rule.validate(value: "PASSWORD")
        #expect(error?.contains("lowercase") == true)
    }

    // MARK: - Digit

    @Test("Password with digit passes when required")
    func digitPresent() {
        let rule = PasswordRule.isPassword(
            requiresUppercase: false,
            requiresLowercase: false,
            requiresDigit: true
        )
        #expect(rule.validate(value: "password1") == nil)
    }

    @Test("Password without digit fails when required")
    func digitMissing() {
        let rule = PasswordRule.isPassword(
            requiresUppercase: false,
            requiresLowercase: false,
            requiresDigit: true
        )
        let error = rule.validate(value: "Password")
        #expect(error?.contains("digit") == true)
    }

    // MARK: - Special Character

    @Test("Password with special character passes when required")
    func specialCharPresent() {
        let rule = PasswordRule.isPassword(
            requiresUppercase: false,
            requiresLowercase: false,
            requiresDigit: false,
            requiresSpecialCharacter: true
        )
        #expect(rule.validate(value: "Password1!") == nil)
    }

    @Test("Password without special character fails when required")
    func specialCharMissing() {
        let rule = PasswordRule.isPassword(
            requiresUppercase: false,
            requiresLowercase: false,
            requiresDigit: false,
            requiresSpecialCharacter: true
        )
        let error = rule.validate(value: "Password1")
        #expect(error?.contains("special character") == true)
    }

    // MARK: - Defaults & Combined

    @Test("Default rule requires uppercase, lowercase, digit, min 8")
    func defaultRuleValidPassword() {
        let rule = PasswordRule.isPassword()
        #expect(rule.validate(value: "Password1") == nil)
    }

    @Test("Default rule rejects all-lowercase short password")
    func defaultRuleRejectsWeak() {
        let rule = PasswordRule.isPassword()
        #expect(rule.validate(value: "weak") != nil)
    }

    @Test("Custom message overrides individual error details")
    func customMessage() {
        let rule = PasswordRule.isPassword(message: "Password is too weak")
        let error = rule.validate(value: "bad")
        #expect(error == "Password is too weak")
    }

    @Test("Multiple failures produce joined message when no custom message")
    func multipleFailureMessages() {
        let rule = PasswordRule.isPassword(
            minLength: 10,
            requiresUppercase: true,
            requiresLowercase: true,
            requiresDigit: true,
            requiresSpecialCharacter: false,
            message: nil
        )
        let error = rule.validate(value: "ab")
        #expect(error?.contains("characters") == true)
        #expect(error?.contains("uppercase") == true)
    }
}
