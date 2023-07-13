//
//  PathCodingKey.swift
//
//
//  Created by 吴哲 on 2023/7/14.
//

import Foundation

public struct PathCodingKey: CodingKey, ExpressibleByStringLiteral, Comparable {
    public var stringValue: String
    public var intValue: Int?

    public static func string(_ string: String) -> PathCodingKey {
        .init(stringValue: string)
    }

    public static func index(_ index: Int) -> PathCodingKey {
        .init(intValue: index)
    }

    public init(stringLiteral value: StaticString) {
        stringValue = value.description
    }

    public init(stringValue: String) {
        self.stringValue = stringValue
    }

    public init(intValue: Int) {
        self.intValue = intValue
        stringValue = String(intValue)
    }

    public static func < (lhs: PathCodingKey, rhs: PathCodingKey) -> Bool {
        switch (lhs.intValue, rhs.intValue) {
        case let (lhs?, rhs?):
            return lhs < rhs
        case (.some, nil):
            return true
        case (nil, .some):
            return false
        case (nil, nil):
            return lhs.stringValue < rhs.stringValue
        }
    }
}
