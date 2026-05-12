//
//  Validate.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 4/1/26.
//

import SwiftUI

enum ValidationState: Equatable {
    case idle
    case editing
    case valid
    case invalid(messages: [String])
    
    var messages: [String] {
        if case .invalid(let messages) = self { return messages }
        return []
    }
}

@propertyWrapper
struct Validate<T: Equatable>: DynamicProperty {
    
    @SwiftUI.State private var value: T
    
    @SwiftUI.State private var state: ValidationState = .idle
    
    private let autoValidate: Bool
    
    private let rules: [any ValidationRule<T>]
    let name: String?
    
    var wrappedValue: T {
        get { value }
        nonmutating set {
            let changed = newValue != value
            value = newValue
            guard changed else { return }
            if autoValidate { validate() } else { state = .editing }
        }
    }
    
    var projectedValue: Binding<T> {
        Binding(
            get: { value },
            set: { newValue in
                let changed = newValue != value
                value = newValue
                guard changed else { return }
                if autoValidate { validate() } else { state = .editing }
            }
        )
    }
    
    var isValid: Bool { state == .valid }
    
    var validationState: ValidationState { state }
    
    init(wrappedValue: T, name: String? = nil, autoValidate: Bool = false, _ rules: any ValidationRule<T>...) {
        self._value = SwiftUI.State(initialValue: wrappedValue)
        self.autoValidate = autoValidate
        self.rules = rules
        self.name = name
    }
    
    @discardableResult
    func validate() -> Bool {
        var errors: [String] = []
        for rule in rules {
            if let message = rule.validate(value: value) {
                errors.append(message)
            }
        }
        if errors.isEmpty {
            state = .valid
            return true
        } else {
            state = .invalid(messages: errors)
            return false
        }
    }
}
