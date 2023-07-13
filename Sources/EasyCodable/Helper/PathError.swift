//
//  PathError.swift
//
//
//  Created by 吴哲 on 2023/7/14.
//

import Foundation

public struct PathError: Swift.Error, CustomStringConvertible {
    let errorDescription: String
    let file: StaticString
    let line: UInt
//    let callStackSymbols: [String] = Thread.callStackSymbols

    static func invalidPath(_ path: Path? = nil, file: StaticString = #fileID, line: UInt = #line) -> PathError {
        if let path = path {
            return .init(errorDescription: "Invalid Path: \(path)", file: file, line: line)
        } else {
            return .init(errorDescription: "Invalid Path", file: file, line: line)
        }
    }

    static func missingValue(file: StaticString = #fileID, line: UInt = #line) -> PathError {
        .init(errorDescription: "Missing Value", file: file, line: line)
    }

    static func other(_ errorDescription: String, file: StaticString = #fileID, line: UInt = #line) -> PathError {
        .init(errorDescription: errorDescription, file: file, line: line)
    }

    public var description: String {
        let strings = [
            errorDescription,
            "\(file):\(line)",
        ]
//        + callStackSymbols.map { "\t\($0)" }
        return strings.joined(separator: "\n")
    }
}

internal func ?? <T>(value: T?, error: PathError) throws -> T {
    guard let value = value else {
        throw error
    }
    return value
}
