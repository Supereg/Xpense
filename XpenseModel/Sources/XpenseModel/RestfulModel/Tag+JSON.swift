//
// Created by Andreas Bauer on 30.03.23.
// Copyright © 2023 TUM LS1. All rights reserved.
//

import Foundation

// MARK: Tag + JSON
extension Tag {
    public static func encodeJSON(from tags: [Tag]) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(tags)
    }

    public static func decodeJSON(from data: Data) throws -> [Tag] {
        let decoder = JSONDecoder()
        return try decoder.decode([Tag].self, from: data)
    }
}
