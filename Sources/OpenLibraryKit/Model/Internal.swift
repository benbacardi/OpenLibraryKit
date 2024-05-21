//
//  Internal.swift
//
//
//  Created by Ben Cardy on 18/05/2024.
//

import Foundation

internal protocol IdentifiableFromKey: Identifiable, Decodable {
    var key: String { get }
    var id: String { get }
}

extension IdentifiableFromKey {
    var id: String {
        if let objectId = key.split(separator: "/").last {
            return String(objectId)
        } else {
            return key
        }
    }
}

extension IdentifiableFromKey {
    static func decodeToArray<K>(from container: KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key) -> [String] where K: CodingKey {
        if let keys = try? container.decode([Self].self, forKey: key) {
            return keys.map { $0.id }
        } else {
            return []
        }
    }
}

internal struct OpenLibraryKey: Codable, IdentifiableFromKey {
    let key: String
}

internal struct OpenLibraryAuthorKey: IdentifiableFromKey, Codable {
    let author: OpenLibraryKey
    var key: String { author.key }
}

internal struct OpenLibraryTypeValue: Codable {
    let type: String
    let value: String
    
    static func decodeIfPresentOrString<K>(from container: KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key) -> String? where K: CodingKey {
        if let stringVersion = try? container.decode(String?.self, forKey: key) {
            return stringVersion
        } else {
            if let dictVersion = try? container.decode(Self.self, forKey: key) {
                return dictVersion.value
            } else {
                return nil
            }
        }
    }
}
