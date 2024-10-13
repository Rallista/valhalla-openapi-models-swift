//
// IsochroneResponse.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
    import AnyCodable
#endif

public struct IsochroneResponse: Codable, Hashable {
    public enum ModelType: String, Codable, CaseIterable {
        case featureCollection = "FeatureCollection"
    }

    public var id: String?
    public var features: [IsochroneFeature]
    public var type: ModelType

    public init(id: String? = nil, features: [IsochroneFeature], type: ModelType) {
        self.id = id
        self.features = features
        self.type = type
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case features
        case type
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(features, forKey: .features)
        try container.encode(type, forKey: .type)
    }
}
