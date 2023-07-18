//
//  KeyedEncodingContainer+Path.swift
//
//
//  Created by 吴哲 on 2023/7/20.
//

import Foundation

// MARK: - PathCodingKey 编码

extension KeyedEncodingContainer<PathCodingKey> {
    mutating func encode<T: Encodable>(_ value: T, context: EasyCodableContext) throws {
        guard let pathComponents = context.path.components(options: context.options).first else {
            throw PathError.invalidPath(context.path)
        }
        try PathEncoder.encode(value, container: &self, pathComponents: pathComponents)
    }
}
