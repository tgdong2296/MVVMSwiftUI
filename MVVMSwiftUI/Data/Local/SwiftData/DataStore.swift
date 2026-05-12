//
//  DataStore.swift
//  PomodoroTimer
//
//  Created by Giang Dong Trinh on 17/12/25.
//

import Foundation
import SwiftData
import Combine

protocol DataStore {
    func fetchAll<T: PersistentModel>(of type: T.Type, sortBy: [SortDescriptor<T>]) throws -> [T]
    
    func fetch<T: PersistentModel>(_ discriptor: FetchDescriptor<T>) throws -> [T]
    
    func fetchFirst<T: PersistentModel>(_ discriptor: FetchDescriptor<T>) throws -> T?
    
    func insert<T: PersistentModel>(_ model: T)
    
    func save() throws
    
    func obverveChanges<T: PersistentModel>(for modelType: T.Type) -> AnyPublisher<[T], Never>
}
