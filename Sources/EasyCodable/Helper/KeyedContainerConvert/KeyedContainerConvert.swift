//
//  KeyedContainerConvert.swift
//
//
//  Created by 吴哲 on 2023/7/14.
//

import Foundation

// swiftlint:disable line_length

extension KeyedDecodingContainer {
    /// 转换类型
    /// - Parameter handler: 回调转换类型
    mutating func convertAsPathCodingKey(_ handler: (inout KeyedDecodingContainer<PathCodingKey>) throws -> Void) throws {
        if let modifier = KeyedContainerMap.shared.decodingContainerModifier(for: self) {
            try modifier.convert(target: &self, handler: handler)
        } else {
            throw KeyedContainerConvertError.unregistered
        }
    }
}

extension KeyedEncodingContainer {
    /// 转换类型
    /// - Parameter handler: 回调转换类型
    mutating func convertAsPathCodingKey(_ handler: (inout KeyedEncodingContainer<PathCodingKey>) throws -> Void) throws {
        if let modifier = KeyedContainerMap.shared.encodingContainerModifier(for: self) {
            try modifier.convert(target: &self, handler: handler)
        } else {
            throw KeyedContainerConvertError.unregistered
        }
    }
}

// swiftlint:enable line_length
