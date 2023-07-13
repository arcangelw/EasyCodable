//
//  Decoder+Path.swift
//
//
//  Created by 吴哲 on 2023/7/18.
//

import Foundation

public extension Decoder {
    func decode<T>(_: T.Type = T.self, at path: Path, options: EasyDecoderOptions = [], decode: (PathDecoder) throws -> T) throws -> T {
        for components in path.components {
            do {
                let context = try PathDecoder(
                    decoder: self,
                    pathComponents: components,
                    options: options
                )
                return try decode(context)
            } catch {}
        }

        throw PathError.invalidPath(path)
    }

    func decode<T>(_ type: T.Type = T.self, at path: Path, options: EasyDecoderOptions = []) throws -> T where T: ElementDecodable {
        try decode(type, at: path, options: options) {
            try T.decode(from: $0)
        }
    }

    func decode<T>(_ type: T.Type = T.self, at path: Path, options: EasyDecoderOptions = []) throws -> T where T: Decodable {
        try decode(type, at: path, options: options) {
            try $0.decode()
        }
    }
}

public protocol ElementDecodable: Decodable {
    static func decode(from decoder: PathDecoder) throws -> Self
}

extension Optional: ElementDecodable where Wrapped: ElementDecodable {
    public static func decode(from decoder: PathDecoder) throws -> Self {
        try Wrapped.decode(from: decoder)
    }
}

extension Array: ElementDecodable where Element: Decodable {
    public static func decode(from decoder: PathDecoder) throws -> [Element] {
        return try LossyDecoder.decode(from: decoder)
    }
}

extension Set: ElementDecodable where Element: Decodable {
    public static func decode(from decoder: PathDecoder) throws -> Set<Element> {
        return try LossyDecoder.decode(from: decoder)
    }
}
