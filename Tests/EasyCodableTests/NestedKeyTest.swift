//
//  NestedKeyTest.swift
//
//
//  Created by 吴哲 on 2023/7/20.
//

@testable import EasyCodable
import XCTest

class NestedKeyTest: XCTestCase {
    let JSON = """
    {
        "title": "The Big Bang Theory",
        "actor.actor_name": "just a test",
        "actor": {
            "actor_name": "Sheldon Cooper",
            "iq": 140
        }
    }
    """

    func testNestedKey() throws {
        struct Episode: Codable {
            @EasyCodable("title")
            var show: String? = nil

            @EasyCodable("actor.actorName")
            var actorName1: String? = nil

            @EasyCodable("actor.actor_name")
            var actorName2: String? = nil

            @EasyCodable(Path(path: "actor.actor_name", noNested: true))
            var noNestedActorName: String? = nil

            @EasyCodable("actor.iq")
            var iq: Int = 0
        }

        let model = try JSONDecoder().decode(Episode.self, from: JSON.data(using: .utf8)!)

        XCTAssertEqual(model.show, "The Big Bang Theory")
        XCTAssertEqual(model.noNestedActorName, "just a test")
        XCTAssertEqual(model.actorName1, "Sheldon Cooper")
        XCTAssertEqual(model.actorName2, "Sheldon Cooper")
        XCTAssertEqual(model.iq, 140)

        let jsonData = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        let actor = (jsonObject["actor"] as? [String: Any])

        XCTAssertEqual(jsonObject["title"] as? String, "The Big Bang Theory")
        XCTAssertEqual(jsonObject["actor.actor_name"] as? String, "just a test")
        XCTAssertEqual(actor?["actorName"] as? String, "Sheldon Cooper")
        XCTAssertEqual(actor?["actor_name"] as? String, "Sheldon Cooper")
        XCTAssertEqual(actor?["iq"] as? Int, 140)
    }
}
