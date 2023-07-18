//
//  PathTests.swift
//
//
//  Created by 吴哲 on 2023/7/14.
//

@testable import EasyCodable
import XCTest

final class PathTests: XCTestCase {
    func testPath() throws {
        XCTAssertEqual("test", PathComponent.key("test"))
        XCTAssertEqual(1337, PathComponent.index(1337))

        let testString = "test"
        let testInt = 1337

        XCTAssertEqual(testString.makePathComponent(), PathComponent.key("test"))
        XCTAssertEqual(testInt.makePathComponent(), PathComponent.index(1337))

        XCTAssertEqualComponents(
            Path("foo"),
            [[.key("foo")]]
        )
        XCTAssertEqualComponents(
            "foo" ?? "bar",
            [[.key("foo")], [.key("bar")]]
        )
        XCTAssertEqualComponents(
            "foo" ?? "bar" ?? "test",
            [[.key("foo")], [.key("bar")], [.key("test")]]
        )
        XCTAssertEqualComponents(
            ("foo" ?? "bar" ?? "test").appending("wow", 42),
            [
                [.key("foo"), .key("wow"), .index(42)],
                [.key("bar"), .key("wow"), .index(42)],
                [.key("test"), .key("wow"), .index(42)],
            ]
        )
        XCTAssertEqualComponents(
            ("foo" ?? "bar" ?? "test").appending("wow") / 42,
            [
                [.key("foo"), .key("wow"), .index(42)],
                [.key("bar"), .key("wow"), .index(42)],
                [.key("test"), .key("wow"), .index(42)],
            ]
        )
        XCTAssertEqualComponents(
            "foo" / "wow" / 42,
            [
                [.key("foo"), .key("wow"), .index(42)],
            ]
        )
        XCTAssertEqualComponents(
            "",
            [[]]
        )
        XCTAssertEqualComponents(
            "foo",
            [["foo"]]
        )
        XCTAssertEqualComponents(
            "foo.bar",
            [["foo", "bar"]]
        )

        XCTAssertEqualComponents(
            .init(path: "foo.bar", noNested: true),
            [["foo.bar"]]
        )
    }
}

private func XCTAssertEqualComponents(_ path: Path, _ components: [[PathComponent]], file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(path.components(options: []), components, file: file, line: line)
}
