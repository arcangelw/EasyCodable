//
//  AnyCodingKey.swift
//
//
//  Created by 吴哲 on 2023/7/13.
//

import Foundation

struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }

    init(index: Int) {
        stringValue = "\(index)"
        intValue = index
    }
}
