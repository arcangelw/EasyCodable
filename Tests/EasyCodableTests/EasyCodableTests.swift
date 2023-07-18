//
//  EasyCodableTests.swift
//
//
//  Created by 吴哲 on 2023/7/20.
//

@testable import EasyCodable
import XCTest

enum Animal: String, Codable {
    case dog
    case cat
    case fish
}

struct ExampleModel: Codable {
    @EasyCodable("aString")
    var stringVal: String = "scyano"

    @EasyCodable("aInt")
    var intVal: Int? = 123_456

    @EasyCodable var array: [Double] = [1.998, 2.998, 3.998]

    @EasyCodable var bool: Bool = false

    @EasyCodable var bool2: Bool = true

    @EasyCodable var unImpl: String?

    @EasyCodable var animal: Animal = .dog

    @EasyCodable var testInt: Int?

    @EasyCodable var testFloat: Float?

    @EasyCodable var testBool: Bool? = nil

    @EasyCodable var testFloats: [Float]?
}

struct SimpleModel: Codable {
    @EasyCodable var val: Int = 2
}

struct OptionalModel: Codable {
    @EasyCodable var val: String? = "default"
}

struct OptionalNullModel: Codable {
    @EasyCodable var val: String?
}

final class EasyCodableTests: XCTestCase {
    private var didSetCount = 0
    var setTestModel: ExampleModel? {
        didSet {
            didSetCount += 1
        }
    }

    func testExample() throws {}

    func testStructCopyOnWrite() {
        let a = ExampleModel()
        let valueInA = a.stringVal
        var b = a
        b.stringVal = "changed!"
        XCTAssertEqual(a.stringVal, valueInA)
    }

    func testBasicUsage() throws {
        let json = #"{"stringVal": "pan", "intVal": "233", "bool": "1", "animal": "cat"}"#
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.intVal, 233)
        XCTAssertEqual(model.stringVal, "pan")
        XCTAssertEqual(model.unImpl, nil)
        XCTAssertEqual(model.array, [1.998, 2.998, 3.998])
        XCTAssertEqual(model.bool, true)
        XCTAssertEqual(model.animal, .cat)
    }

    func testBasicPath() throws {
        let json = #"{"aString": "pan.aString", "stringVal": "pan.stringVal", "intVal": "233", "bool": "1", "animal": "cat"}"#
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.intVal, 233)
        XCTAssertEqual(model.stringVal, "pan.aString")
        XCTAssertEqual(model.unImpl, nil)
        XCTAssertEqual(model.array, [1.998, 2.998, 3.998])
        XCTAssertEqual(model.bool, true)
        XCTAssertEqual(model.animal, .cat)
    }

    func testCodingKeyEncode() throws {
        let json = """
        {"intVal": 233, "stringVal": "pan"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)

        let data = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["aInt"] as? Int, 233)
        XCTAssertEqual(jsonObject["aString"] as? String, "pan")
    }

    func testCodingKeyDecode() throws {
        let json = """
        {"aString": "pan", "aInt": "233"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.intVal, 233)
        XCTAssertEqual(model.stringVal, "pan")
    }

    func testDefaultVale() throws {
        let json = """
        {"intVal": "wrong value"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.intVal, 123_456)
        XCTAssertEqual(model.stringVal, "scyano")
        XCTAssertEqual(model.animal, .dog)
    }

    func testNested() throws {
        struct RootModel: Codable {
            @EasyCodable("rt") var root = SubRootModelCodec()
            var root2: SubRootModel? = SubRootModel()
        }

        struct SubRootModelCodec: Codable {
            @EasyCodable var value: ExampleModel?
            @EasyCodable var value2 = ExampleModel()
        }

        struct SubRootModel: Codable {
            var value: ExampleModel?
            var value2: ExampleModel? = ExampleModel()
        }

        let json = """
        {"rt": {"value": {"stringVal":"x"}}, "root2": {"value": {"stringVal":"y"}}}
        """
        let model = try JSONDecoder().decode(RootModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.root.value?.stringVal, "x")
        XCTAssertEqual(model.root.value2.stringVal, "scyano")
        XCTAssertEqual(model.root2?.value?.stringVal, "y")
        XCTAssertEqual(model.root2?.value2?.stringVal, nil)
    }

    func testDidSet() throws {
        didSetCount = 0

        let json = """
        {"intVal": 233, "stringVal": "pan"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        setTestModel = model
        setTestModel!.intVal = 222
        setTestModel!.stringVal = "ok"

        XCTAssertEqual(didSetCount, 3)
    }

    func testLiteral() throws {
        let model = ExampleModel(stringVal: "1", intVal: 1, array: [], bool: true, bool2: true, unImpl: "123", animal: .cat, testInt: 111, testFloat: 1.2, testBool: true, testFloats: [1, 2])
        XCTAssertEqual(model.unImpl, "123")
        XCTAssertEqual(model.testFloats, [1, 2])
    }

    func testOptionalWithValue() throws {
        let json = """
        {"val": "default2"}
        """
        let model = try JSONDecoder().decode(OptionalModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.val, "default2")
    }

    func testOptionalWithNull() throws {
        let json = """
        {"val": null}
        """
        let model = try JSONDecoder().decode(OptionalNullModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.val, nil)

        let json2 = """
        {}
        """
        let model2 = try JSONDecoder().decode(OptionalNullModel.self, from: json2.data(using: .utf8)!)
        XCTAssertEqual(model2.val, nil)
    }

    func testBasicTypeBridge() throws {
        let json = """
        {"intVal": "1", "stringVal": 2, "bool": "true"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.intVal, 1)
        XCTAssertEqual(model.stringVal, "2")
        XCTAssertEqual(model.bool, true)

        let jsonData = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["aString"] as? String, "2")
    }

    func testMutiThread() throws {
        let expectation = XCTestExpectation(description: "")
        let expectation2 = XCTestExpectation(description: "")

        var array: [ExampleModel] = []
        var array2: [ExampleModel] = []

        DispatchQueue.global().async {
            do {
                for i in 5000 ..< 6000 {
                    let json = """
                    {"intVal": \(i)}
                    """
                    let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
                    XCTAssertEqual(model.intVal, i)
                    XCTAssertEqual(model.stringVal, "scyano")
                    XCTAssertEqual(model.unImpl, nil)
                    XCTAssertEqual(model.array, [1.998, 2.998, 3.998])
                    // print(model.intVal)

                    array.append(model)
                }
                expectation.fulfill()
            } catch let e {
                print(e)
            }
        }

        DispatchQueue.global().async {
            do {
                for i in 1 ..< 1000 {
                    let json = """
                    {"intVal": \(i), "stringVal": "string_\(i)", "array": [123456789]}
                    """
                    let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
                    XCTAssertEqual(model.intVal, i)
                    XCTAssertEqual(model.stringVal, "string_\(i)")
                    XCTAssertEqual(model.unImpl, nil)
                    XCTAssertEqual(model.array, [123_456_789])

                    array2.append(model)
                }
                expectation2.fulfill()
            } catch let e {
                print(e)
            }
        }

        wait(for: [expectation, expectation2], timeout: 10.0)
    }

    func testCustomCodable() throws {
        struct CustomModel: Codable {
            @EasyCodable
            var aString: String = "a"
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: PathCodingKey.self)
                _aString = try container.decode(EasyCodable<String>.self, forKey: "aString")
            }

            func encode(to encoder: Encoder) throws {
                let container = encoder.container(keyedBy: PathCodingKey.self)
                try container.encode(_aString, forKey: "aString")
            }
        }

        let json = """
        {"aString": "abc"}
        """
        let model = try JSONDecoder().decode(CustomModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.aString, "abc")
        let jsonData = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["aString"] as? String, "abc")
    }

    func testAutoCodable() throws {
        struct CustomModel: Codable {
            @EasyCodable
            var aString: String = "a"

            @EasyCodable("aIntValue")
            var aInt: Int = 100

            init(from decoder: Decoder) throws {
                try container(from: decoder)
            }

            func encode(to encoder: Encoder) throws {
                try container(from: encoder)
            }
        }

        let json = """
        {"aString": "abc", "aInt": 10}
        """
        let model = try JSONDecoder().decode(CustomModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.aString, "abc")
        XCTAssertEqual(model.aInt, 10)
        let jsonData = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["aString"] as? String, "abc")
        XCTAssertEqual(jsonObject["aIntValue"] as? Int, 10)
    }
}
