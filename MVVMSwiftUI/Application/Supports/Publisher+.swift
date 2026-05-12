import Combine

extension Publisher {
    public func sink() -> AnyCancellable {
        return self.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
}

extension Publisher {
    func sink<Object: AnyObject>(with object: Object,
                                 receiveCompletion: @escaping ((Object, Subscribers.Completion<Self.Failure>) -> Void),
                                 receiveValue: @escaping ((Object, Self.Output) -> Void)) -> AnyCancellable {
        weak let weakObject = object
        
        return sink { completion in
            guard let object = weakObject else { return }
            receiveCompletion(object, completion)
        } receiveValue: { output in
            guard let object = weakObject else { return }
            receiveValue(object, output)
        }
    }
}

extension Publisher where Self.Failure == Never {
    public func sink<Object: AnyObject>(with object: Object,
                                        receiveValue: @escaping ((Object, Self.Output) -> Void)) -> AnyCancellable {
        weak let weakObject = object
        
        return sink { output in
            guard let object = weakObject else { return }
            receiveValue(object, output)
        }
    }
}

extension Publisher {
    func mapToOptional() -> Publishers.Map<Self, Self.Output?> {
        return self.map { $0 as Self.Output? }
    }
}
