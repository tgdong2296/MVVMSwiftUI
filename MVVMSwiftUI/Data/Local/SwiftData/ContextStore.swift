//
//  ContextStore.swift
//  PomodoroTimer
//
//  Created by Giang Dong Trinh on 17/12/25.
//

import SwiftData
import Foundation
import FactoryKit
import Combine
import CoreData

final class ContextStore: DataStore {
    private let modelContext: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.modelContext = ModelContext(modelContainer)
    }
    
    func fetchAll<T>(of type: T.Type, sortBy: [SortDescriptor<T>]) throws -> [T] where T: PersistentModel {
        let fetch = FetchDescriptor(sortBy: sortBy)
        return try modelContext.fetch(fetch)
    }
    
    func fetchFirst<T: PersistentModel>(_ discriptor: FetchDescriptor<T>) throws -> T? {
        return try modelContext.fetch(discriptor).first
    }
    
    func fetch<T>(_ discriptor: FetchDescriptor<T>) throws -> [T] where T: PersistentModel {
        return try modelContext.fetch(discriptor)
    }
    
    func insert<T>(_ model: T) where T: PersistentModel {
        modelContext.insert(model)
    }
    
    func save() throws {
        try modelContext.save()
    }
    
    func obverveChanges<T: PersistentModel>(for modelType: T.Type) -> AnyPublisher<[T], Never> {
        return modelContext.publisher(for: modelType)
    }
}

extension ModelContext {
    func publisher<T: PersistentModel>(for modelType: T.Type) -> AnyPublisher<[T], Never> {
        // Use NotificationCenter to observe model context changes
        NotificationCenter.default.publisher(for: ModelContext.didSave, object: self)
            .receive(on: DispatchQueue.main)
            .compactMap { _ in
                try? self.fetch(FetchDescriptor<T>())
            }
            .eraseToAnyPublisher()
    }
}
