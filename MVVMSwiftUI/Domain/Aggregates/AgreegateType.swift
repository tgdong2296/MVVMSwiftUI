//
//  AgreegateType.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 4/3/26.
//

import SwiftUI

protocol AgreegateType: AnyObject, Observable {
    var state: ViewState { get }
}
