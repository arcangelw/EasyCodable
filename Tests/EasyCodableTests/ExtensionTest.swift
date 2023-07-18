//
//  ExtensionTest.swift
//
//
//  Created by 吴哲 on 2023/7/20.
//

@testable import EasyCodable
import XCTest

final class ExtensionTest: XCTestCase {
    struct HashableModel: Codable, Hashable {
        @EasyCodable var value1: String?
    }

    struct NavtiveHashableModel: Codable, Hashable {
        var value1: String?
    }

    struct NavtiveHashableModel2: Codable, Hashable {
        var value1: String?
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHashable() throws {
        let a = HashableModel(value1: "abc")
        let b = HashableModel(value1: "abc")

        let c = NavtiveHashableModel(value1: "abc")
        let d = NavtiveHashableModel2(value1: "abc")

        XCTAssertEqual(a.hashValue, b.hashValue)
        XCTAssertEqual(a.hashValue, c.hashValue)
        XCTAssertEqual(c.hashValue, d.hashValue)
    }
}
