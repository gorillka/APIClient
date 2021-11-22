//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

@resultBuilder
public enum HTTPHeadersBuilder {
    public static func buildBlock(_ components: [(String, String)]...) -> [(String, String)] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: (String, String)) -> [(String, String)] {
        [expression]
    }

    public static func buildArray(_ components: [[(String, String)]]) -> [(String, String)] {
        components.flatMap { $0 }
    }

    public static func buildEither(first component: [(String, String)]) -> [(String, String)] {
        component
    }

    public static func buildEither(second component: [(String, String)]) -> [(String, String)] {
        component
    }

    public static func buildOptional(_ component: [(String, String)]?) -> [(String, String)] {
        component ?? []
    }
}

public extension HTTPHeaders {
    init(@HTTPHeadersBuilder _ builder: () -> [(String, String)]) {
        self.init(builder())
    }
}
