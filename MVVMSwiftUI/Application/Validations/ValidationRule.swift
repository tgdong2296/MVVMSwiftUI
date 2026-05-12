//
//  ValidationRule.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 4/1/26.
//

protocol ValidationRule<Value> {
    
    associatedtype Value
    
    func validate(value: Value) -> String?
}
