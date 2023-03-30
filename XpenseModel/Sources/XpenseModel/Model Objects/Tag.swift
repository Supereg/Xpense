//
// Created by Andreas Bauer on 30.03.23.
// Copyright © 2023 TUM LS1. All rights reserved.
//

import Foundation

public struct Tag: Codable {
    public let id: UUID
    public var name: String
    public var color: String

    public var icon: URL?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case color

        case icon = "icon_url"
    }
}

// MARK: Tag + Hashable, Equatable
extension Tag: Hashable, Equatable {}
