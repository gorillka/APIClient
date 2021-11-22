//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

public protocol RequestRepresentable {
    var httpRequest: HTTPRequest { get }
}

public extension RequestRepresentable where Self: ResponseDecodable {
    func request<Value>() -> Request<Value>
        where RawValue == Unwrap<Value>, Value == FinalValue, FallbackValue: Decodable
    {
        .init(responseValue: self, request: httpRequest)
    }

    func request<Value>() -> Request<Value> where Value: Decodable, RawValue == Value, FallbackValue: Decodable {
        .init(responseValue: self, request: httpRequest)
    }

    func request<Value>() -> Request<Value> where Value: Decodable, RawValue == Value {
        .init(self, request: httpRequest)
    }

    func request<Value>() -> Request<Value> where RawValue == Unwrap<FinalValue>, Value == FinalValue {
        .init(self, request: httpRequest)
    }
}
