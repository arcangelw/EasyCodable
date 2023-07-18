//
//  LossyDecoder.swift
//
//
//  Created by 吴哲 on 2023/7/18.
//

import Foundation

// MARK: - Lossy缺省转换 `[1, null, 3, null, 5] -> [1, 3, 5]`

protocol LossyDecodable: Decodable {
    associatedtype Element: Decodable
    static func backed(by array: [Element]) -> Self
}

extension Array: LossyDecodable where Element: Decodable {
    static func backed(by array: [Element]) -> Self {
        array
    }
}

extension Set: LossyDecodable where Element: Decodable {
    static func backed(by array: [Element]) -> Self {
        Set(array)
    }
}

struct Lossy<Value: Decodable>: Decodable {
    let value: Value?
    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            value = try container.decode(Value.self)
        } catch {
            value = nil
        }
    }
}

enum LossyDecoder {
    // swiftlint:disable line_length
    static func decode<Value: LossyDecodable>(container: inout KeyedDecodingContainer<PathCodingKey>, pathComponents: [PathComponent], options: EasyCodableOptions) throws -> Value {
        guard options.contains(.lossy) else {
            return try PathDecoder.decode(container: &container, pathComponents: pathComponents)
        }
        let lossy = try PathDecoder.decode([Lossy<Value.Element>].self, container: &container, pathComponents: pathComponents)
        return .backed(by: lossy.compactMap(\.value))
    }
    // swiftlint:enable line_length
}
