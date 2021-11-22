//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

@resultBuilder
public enum PathComponentBuilder {
    public static func buildBlock(_ components: [String]...) -> [String] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: String) -> [String] {
        [expression]
    }

    public static func buildArray(_ components: [[String]]) -> [String] {
        components.flatMap { $0 }
    }

    public static func buildEither(first component: [String]) -> [String] {
        component
    }

    public static func buildEither(second component: [String]) -> [String] {
        component
    }

    public static func buildOptional(_ component: [String]?) -> [String] {
        component ?? []
    }
}

public extension Array where Element == PathComponent {
    init(@PathComponentBuilder _ builder: () -> [String]) {
        self.init(builder().map(PathComponent.init(stringLiteral:)))
    }
}
