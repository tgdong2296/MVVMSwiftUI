//
//  ViewState+.swift
//  MVVMSwiftUI
//
//  Created by Giang Dong Trinh on 23/6/26.
//

func combine(_ viewStates: [ViewState]) -> ViewState {
    let errors = viewStates
        .compactMap { state -> [String]? in
            guard case let .error(messages) = state else { return nil }
            return messages
        }
        .flatMap { $0 }
    if !errors.isEmpty { return .error(errors) }
    if viewStates.contains(.loading) { return .loading }
    if viewStates.allSatisfy({ $0 == .indie }) { return .indie }
    return .success
}
