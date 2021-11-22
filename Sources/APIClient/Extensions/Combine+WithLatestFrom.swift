//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Combine

extension Publisher {
    func withLatestFrom<Other: Publisher>(
        _ other: Other
    ) -> AnyPublisher<Other.Output, Other.Failure>
        where Failure == Other.Failure
    {
        other
            .map { second in map { _ in second } }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

extension Publisher {
    func withLatestFrom<Other: Publisher, Transformed>(
        _ other: Other,
        _ selector: @escaping (Output, Other.Output) -> Transformed
    ) -> AnyPublisher<Transformed, Other.Failure>
        where Failure == Other.Failure
    {
        other
            .map { second in map { first in selector(first, second) } }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
