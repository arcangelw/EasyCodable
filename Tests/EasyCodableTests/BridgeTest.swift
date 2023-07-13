//
//  BridgeTest.swift
//
//
//  Created by 吴哲 on 2023/7/17.
//

@testable import EasyCodable
import XCTest

final class BridgeTest: XCTestCase {
    func testBoolBridge() throws {
        let trueStringValue = "True"
        let falseStringValue = "False"
        let trueValue = true
        let falseValue = false

        XCTAssertEqualBridge(trueStringValue, "True")
        XCTAssertEqualBridge(falseStringValue, "False")

        XCTAssertEqualBridge(trueValue, "true")
        XCTAssertEqualBridge(falseValue, "false")
        XCTAssertEqualBridge(trueStringValue, trueValue)
        XCTAssertEqualBridge(falseStringValue, falseValue)
        XCTAssertEqualBridge(1, trueValue)
        XCTAssertEqualBridge(0, falseValue)
        XCTAssertEqualBridge(trueValue, 1)
        XCTAssertEqualBridge(falseValue, 0)
        XCTAssertEqualBridge("1", trueValue)
        XCTAssertEqualBridge("0", falseValue)
        XCTAssertEqualBridge(trueValue, NSNumber(value: trueValue))
        XCTAssertEqualBridge(falseValue, NSNumber(value: falseValue))
        XCTAssertEqualBridge(trueStringValue, NSNumber(value: trueValue))
        XCTAssertEqualBridge(falseStringValue, NSNumber(value: falseValue))
    }

    func testIntegerBridge() throws {
        XCTAssertEqualBridge("90293929", Int(90_293_929))
        XCTAssertEqualBridge("90293929", UInt(90_293_929))
        XCTAssertEqualBridge("123", Int8(123))
        XCTAssertEqualBridge("1234", Int16(1234))
        XCTAssertEqualBridge("90293929", Int32(90_293_929))
        XCTAssertEqualBridge("90293929", Int64(90_293_929))
        XCTAssertEqualBridge("123", UInt8(123))
        XCTAssertEqualBridge("1234", UInt16(1234))
        XCTAssertEqualBridge("90293929", UInt32(90_293_929))
        XCTAssertEqualBridge("90293929", UInt64(90_293_929))

        XCTAssertEqualBridge(90_293_929, Int(90_293_929))
        XCTAssertEqualBridge(90_293_929, UInt(90_293_929))
        XCTAssertEqualBridge(123, Int8(123))
        XCTAssertEqualBridge(1234, Int16(1234))
        XCTAssertEqualBridge(90_293_929, Int32(90_293_929))
        XCTAssertEqualBridge(90_293_929, Int64(90_293_929))
        XCTAssertEqualBridge(123, UInt8(123))
        XCTAssertEqualBridge(1234, UInt16(1234))
        XCTAssertEqualBridge(90_293_929, UInt32(90_293_929))
        XCTAssertEqualBridge(90_293_929, UInt64(90_293_929))
    }

    func testFloatBridge() throws {
        // let numValue = NSNumber(value: 3.1415926)
        let floatValue: Float = 3.1415926
        let pi = Double.pi
        let doubleValue = 3.1415926
        let cgfloatValue: CGFloat = 3.1415926
        // FIXME: - Float 转换过程中精度丢失严重
        // XCTAssertEqualBridge(floatValue, "\(floatValue)")
        XCTAssertEqualBridge(doubleValue, "3.1415926")
        XCTAssertEqualBridge(cgfloatValue, "3.1415926")
        XCTAssertEqualBridge(pi, "\(pi)")
        XCTAssertEqualBridge("\(floatValue)", floatValue)
        XCTAssertEqualBridge("3.1415926", doubleValue)
        XCTAssertEqualBridge("3.1415926", cgfloatValue)
        XCTAssertEqualBridge(floatValue, NSNumber(value: floatValue))
        XCTAssertEqualBridge(doubleValue, NSNumber(value: 3.1415926))
        XCTAssertEqualBridge(cgfloatValue, NSNumber(value: 3.1415926))
        XCTAssertEqualBridge(doubleValue, NSDecimalNumber(value: 3.1415926))
        XCTAssertEqualBridge(cgfloatValue, NSDecimalNumber(value: 3.1415926))
        XCTAssertEqualBridge("3.1415926", NSDecimalNumber(value: 3.1415926))
        XCTAssertEqualBridge("3.1415926", NSDecimalNumber(value: 3.1415926))
    }

    func testString2NumberBridge() throws {
        XCTAssertNil(NSNumber._transform(from: "_ssffss"))
        XCTAssertEqualBridge("999028280", NSNumber(value: 999_028_280))
        XCTAssertEqualBridge("0xFFFFFF", NSNumber(value: 16_777_215))
        XCTAssertEqualBridge("-0xFFFFF0", NSNumber(value: -16_777_200))
        XCTAssertEqualBridge("0x3.243f69a25b093b1224c6", NSNumber(value: 3.1415926))
        XCTAssertEqualBridge("-0x3.243f69a25b093b1224c6", NSNumber(value: -3.1415926))
    }

    func testNumber2String() throws {
        XCTAssertEqualBridge(-Int8.max, "-\(Int8.max)")
        XCTAssertEqualBridge(-Int.max, "-\(Int.max)")
        XCTAssertEqualBridge(Int.max, "\(Int.max)")
        XCTAssertEqualBridge(-Int64.max, "-\(Int64.max)")
        XCTAssertEqualBridge(Int64.max, "\(Int64.max)")
        XCTAssertEqualBridge(UInt.max, "\(UInt.max)")
        XCTAssertEqualBridge(999_028_280, "999028280")
        XCTAssertEqualBridge(Double.pi, "\(Double.pi)")
    }
}

private func XCTAssertEqualBridge<T, V>(_ value: V, _ equalValue: T?, file: StaticString = #file, line: UInt = #line) where T: _EasyBuiltInBridgeType, T: Equatable, V: Equatable {
    let transformValue = T._transform(from: value)
    XCTAssertEqual(transformValue, equalValue, file: file, line: line)
}
