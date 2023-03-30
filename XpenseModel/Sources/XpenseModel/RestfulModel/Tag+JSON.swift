//
// Created by Andreas Bauer on 30.03.23.
// Copyright © 2023 TUM LS1. All rights reserved.
//

import Foundation

// MARK: Tag + JSON
extension Tag {
    public static func encodeJSON(from tags: [Tag]) throws -> Data {
        // TODO 3.1 Use a `JSONEncoder` to encode the provided tags array
        Data()
    }

    public static func decodeJSON(from data: Data) throws -> [Tag] {
        // TODO 3.2 Use a `JSONDecoder` to decode the provided Data into a Tag array
        []
    }
}
