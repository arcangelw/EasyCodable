//
//  EasyCodingKey.swift
//
//
//  Created by 吴哲 on 2023/7/13.
//

import Foundation

public enum EasyCodingKey {
    case noNested(String)
    case nested([String])

    public init(key: String, noNested: Bool = false) {
        if noNested {
            self = .noNested(key)
        } else {
            let comps = key.components(separatedBy: ".")
            if comps.count > 1 {
                self = .nested(comps)
            } else {
                self = .noNested(key)
            }
        }
    }
}
