//
//  NotEmptyStringRuleTests.swift
//  MVVMSwiftUITests
//

import Testing
@testable import MVVMSwiftUI

@Suite("NotEmptyStringRule")
struct NotEmptyStringRuleTests {

    let rule = NotEmptyStringRule.isNotEmpty(message: "This field is required")

    @Test("Non-empty string returns nil")
    func nonEmptyString() {
        #expect(rule.validate(value: "hello") == nil)
        #expect(rule.validate(value: "a") == nil)
        #expect(rule.validate(value: "  text  ") == nil)
    }

    @Test("Empty string returns the configured message")
    func emptyString() {
        #expect(rule.validate(value: "") == "This field is required")
    }

    @Test("Whitespace-only string returns the configured message")
    func whitespaceOnlyString() {
        #expect(rule.validate(value: "   ") == "This field is required")
        #expect(rule.validate(value: "\n\t") == "This field is required")
        #expect(rule.validate(value: "\n") == "This field is required")
    }

    @Test("Returns the exact configured message")
    func customMessage() {
        let customRule = NotEmptyStringRule.isNotEmpty(message: "Name cannot be blank")
        #expect(customRule.validate(value: "") == "Name cannot be blank")
    }
}
