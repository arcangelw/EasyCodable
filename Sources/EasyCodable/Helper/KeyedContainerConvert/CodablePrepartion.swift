//
//  CodablePrepartion.swift
//
//
//  Created by 吴哲 on 2023/7/14.
//

import Foundation

/// 创建一个空的 Codable Container
final class CodablePrepartion: Codable {
    var keyedDecodingContainer: KeyedDecodingContainer<PathCodingKey>
    var keyedEncodingContainer: KeyedEncodingContainer<PathCodingKey>?

    public required init(from decoder: Decoder) throws {
        keyedDecodingContainer = try decoder.container(keyedBy: PathCodingKey.self)
    }

    public func encode(to encoder: Encoder) throws {
        keyedEncodingContainer = encoder.container(keyedBy: PathCodingKey.self)
    }
}
