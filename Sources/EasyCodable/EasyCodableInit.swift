//
//  EasyCodableInit.swift
//
//
//  Created by 吴哲 on 2023/7/19.
//

import Foundation

// swiftlint:disable line_length

extension EasyCodable where Value: Codable {
    public init<Wrapped>(_ path: Path? = nil, options: EasyCodableOptions = .all) where Value == Wrapped? {
        self.init(
            defaultValue: Wrapped?.none,
            executor: .init(
                context: .init(givenPath: path, options: options),
                transfromer: nil
            )
        )
    }

    public init(wrappedValue: Value, _ path: Path? = nil, options: EasyCodableOptions = .all) {
        self.init(
            defaultValue: wrappedValue,
            executor: .init(
                context: .init(givenPath: path, options: options),
                transfromer: nil
            )
        )
    }
}

extension EasyCodable {
    public init<Wrapped, T: TransformType>(_ path: Path? = nil, options: EasyCodableOptions = .all, transformer: T) where Value == Wrapped? {
        self.init(
            defaultValue: Wrapped?.none,
            executor: .init(
                context: .init(givenPath: path, options: options),
                transfromer: .init(transformer)
            )
        )
    }

    public init<T: TransformType>(wrappedValue: Value, _ path: Path? = nil, options: EasyCodableOptions = .all, transformer: T) {
        self.init(
            defaultValue: wrappedValue,
            executor: .init(
                context: .init(givenPath: path, options: options),
                transfromer: .init(transformer)
            )
        )
    }
}

// swiftlint:enable line_length
