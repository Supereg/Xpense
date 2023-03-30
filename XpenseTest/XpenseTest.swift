//
// Created by Andreas Bauer on 30.03.23.
//

import Foundation

import XCTest
@testable import Xpense
@testable import XpenseModel

extension Tag {
    static func accept(visitor: XpenseTest.CodableTestVisitor) throws {
        // we use this as a workaround to check if Codable is implemented!
        try visitor.visit(Self.self)
    }
}

protocol TransactionWithTag {
    var tags: [Tag]? { get }
}

extension TransactionWithTag {
    var tags: [Tag]? {
        // see testTransactionTagProperty
        XCTFail("Transaction doesn't properly implement the tags property!")
        return nil
    }
}

protocol TagInitializer {
    init(id: UUID, name: String, color: String, url: URL?)
}

extension Transaction: TransactionWithTag {}

class XpenseTest: XCTestCase {
    static let string = "{\"id\": \"E3F91FD8-B9D7-41E8-9E4A-C704EF2011CE\", \"name\": \"food\", \"color\": \"green\"}"
    static let string_with_url = "{\"id\": \"E3F91FD8-B9D7-41E8-9E4A-C704EF2011CE\", \"name\": \"food\", \"color\": \"green\", \"icon_url\": \"https://webstockreview.net/images/clipart-food-simple-14.png\"}"

    override func setUp() {
        super.setUp()
    }

    struct CodableTestVisitor {
        let string: String

        func visit<T: Equatable>(_ object: T.Type = T.self) throws {
            XCTFail("\(T.self) doesn't conform to Codable!")
        }

        func visit<T: Codable & Equatable>(_ object: T.Type = T.self) throws {
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            let tag = try decoder.decode(T.self, from: string.data(using: .utf8)!)
            let data = try encoder.encode(tag)
            let tag0 = try decoder.decode(T.self, from: data)

            XCTAssertEqual(tag, tag0, "Codable implementation doesn't work properly!")
        }
    }

    // part 1
    func testTagCodable() throws {
        let visitor = CodableTestVisitor(string: XpenseTest.string)
        XCTAssertNoThrow(try Tag.accept(visitor: visitor), "Unexpected error thrown on Codable implementation! Are any properties missing?")
    }

    // part 1
    func testTransactionTagProperty() {
        let transaction = Transaction(amount: 2, description: "description", account: UUID())
        XCTAssertEqual(transaction.tags, nil, "Unexpected value found in tags!")
    }

    // part 2
    func testIconsWithCodingKeys() throws {
        let visitor = CodableTestVisitor(string: XpenseTest.string_with_url)
        XCTAssertNoThrow(try Tag.accept(visitor: visitor), "Unexpected error thrown on Codable implementation! Are any properties missing?")
    }

    // part 3
    func testEncodeAndDecodeMethods() throws {
        let tag = try Tag.decodeJSON(from: "[\(XpenseTest.string)]".data(using: .utf8)!)
        let data = try Tag.encodeJSON(from: tag)
        let tag0 = try Tag.decodeJSON(from: data)
        XCTAssertEqual(tag, tag0)

        let tag_url = try Tag.decodeJSON(from: "[\(XpenseTest.string_with_url)]".data(using: .utf8)!)
        let data_url = try Tag.encodeJSON(from: tag_url)
        let tag0_url = try Tag.decodeJSON(from: data_url)
        XCTAssertEqual(tag_url, tag0_url)
    }
}
