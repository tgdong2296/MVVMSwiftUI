//
//  EmailRuleTests.swift
//  MVVMSwiftUITests
//

import Testing
@testable import MVVMSwiftUI

@Suite("EmailRule")
struct EmailRuleTests {

    let rule = EmailRule.isEmail()

    @Test("Valid emails return nil")
    func validEmails() {
        #expect(rule.validate(value: "test@example.com") == nil)
        #expect(rule.validate(value: "user.name+tag@domain.co") == nil)
        #expect(rule.validate(value: "USER@DOMAIN.COM") == nil)
        #expect(rule.validate(value: "user123@sub.domain.org") == nil)
    }

    @Test("Invalid emails return an error message")
    func invalidEmails() {
        #expect(rule.validate(value: "") != nil)
        #expect(rule.validate(value: "notanemail") != nil)
        #expect(rule.validate(value: "@domain.com") != nil)
        #expect(rule.validate(value: "user@") != nil)
        #expect(rule.validate(value: "user @domain.com") != nil)
        #expect(rule.validate(value: "user@domain") != nil)
    }

    @Test("Default error message is returned")
    func defaultErrorMessage() {
        let error = rule.validate(value: "invalid")
        #expect(error == "Invalid email address")
    }

    @Test("Custom error message is returned")
    func customErrorMessage() {
        let customRule = EmailRule.isEmail(message: "Please enter a valid email")
        #expect(customRule.validate(value: "invalid") == "Please enter a valid email")
    }

    @Test("Valid email returns nil with custom message configured")
    func validEmailWithCustomMessage() {
        let customRule = EmailRule.isEmail(message: "Error")
        #expect(customRule.validate(value: "user@example.com") == nil)
    }
}
