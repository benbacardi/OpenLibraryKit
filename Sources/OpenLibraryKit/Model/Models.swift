//
//  OpenLibraryBook.swift
//
//
//  Created by Ben Cardy on 17/05/2024.
//

import Foundation
import APIClient

public struct OpenLibraryError: Codable, LocalizedError {
    public let key: String
    public let error: String
    
    public var errorDescription: String? {
        error
    }
}

public struct OpenLibraryLink: Codable {
    public let title: String
    public let url: URL
}

public struct OpenLibraryCoverImage: Codable {
    public let id: Int
    
    public enum CoverImageSize: String {
        case small = "S"
        case medium = "M"
        case large = "L"
    }
    
    public func url(size: CoverImageSize = .small) -> URL? {
        return URL(string: "\(OpenLibraryConstants.coverURL)id/\(id)-\(size.rawValue).jpg")
    }
}

/// https://openlibrary.org/authors/OL34184A.json
public struct OpenLibraryAuthor: Codable, IdentifiableFromKey {
    public let key: String
    public let name: String
    public let personalName: String?
    public let alternateNames: [String]?
    public let photos: [Int]?
    public let bio: String?
    public let links: [OpenLibraryLink]?
    
    enum CodingKeys: String, CodingKey {
        case key
        case name
        case personalName = "personal_name"
        case alternateNames = "alternate_names"
        case photos
        case bio
        case links
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        name = try container.decode(String.self, forKey: .name)
        personalName = try container.decodeIfPresent(String.self, forKey: .personalName)
        alternateNames = try container.decodeIfPresent([String].self, forKey: .alternateNames)
        photos = try container.decodeIfPresent([Int].self, forKey: .photos)
        links = try container.decodeIfPresent([OpenLibraryLink].self, forKey: .links)
        bio = OpenLibraryTypeValue.decodeIfPresentOrString(from: container, forKey: .bio)
    }
}

/// https://openlibrary.org/works/OL45804W.json
public struct OpenLibraryWork: Decodable, IdentifiableFromKey {
    public let title: String
    public let key: String
    public let authors: [String]
    public let description: String?
    public let covers: [OpenLibraryCoverImage]
    public let subjectPlaces: [String]?
    public let subjects: [String]?
    public let subjectPeople: [String]?
    public let subjectTimes: [String]?
    
    enum CodingKeys: String, CodingKey {
        case title
        case key
        case authors
        case description
        case covers
        case subjectPlaces = "subject_places"
        case subjects
        case subjectPeople = "subject_people"
        case subjectTimes = "subject_times"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        key = try container.decode(String.self, forKey: .key)
        subjectPlaces = try container.decodeIfPresent([String].self, forKey: .subjectPlaces)
        subjects = try container.decodeIfPresent([String].self, forKey: .subjects)
        subjectPeople = try container.decodeIfPresent([String].self, forKey: .subjectPeople)
        subjectTimes = try container.decodeIfPresent([String].self, forKey: .subjectTimes)
        description = OpenLibraryTypeValue.decodeIfPresentOrString(from: container, forKey: .description)
        authors = OpenLibraryAuthorKey.decodeToArray(from: container, forKey: .authors)
        if let coverIds = try container.decodeIfPresent([Int].self, forKey: .covers) {
            covers = coverIds.map { OpenLibraryCoverImage(id: $0) }
        } else {
            covers = []
        }
    }
}

/// https://openlibrary.org/works/OL45804W/editions.json
public struct OpenLibraryEdition: Codable, IdentifiableFromKey {
    public let title: String
    public let key: String
    public let authors: [String]
    public let isbn13: [String]?
    public let isbn10: [String]?
    public let publishDate: String?
    public let publishers: [String]?
    public let editionName: String?
    public let physicalFormat: String?
    public let subjects: [String]?
    public let fullTitle: String?
    public let works: [String]
    public let covers: [OpenLibraryCoverImage]
    public let numberOfPages: Int?
    
    enum CodingKeys: String, CodingKey {
        case title
        case key
        case authors
        case isbn13 = "isbn_13"
        case isbn10 = "isbn_10"
        case publishDate = "publish_date"
        case publishers
        case editionName = "edition_name"
        case physicalFormat = "physical_format"
        case subjects
        case fullTitle = "full_title"
        case works
        case covers
        case numberOfPages = "number_of_pages"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        key = try container.decode(String.self, forKey: .key)
        isbn13 = try container.decodeIfPresent([String].self, forKey: .isbn13)
        isbn10 = try container.decodeIfPresent([String].self, forKey: .isbn10)
        publishDate = try container.decodeIfPresent(String.self, forKey: .publishDate)
        publishers = try container.decodeIfPresent([String].self, forKey: .publishers)
        editionName = try container.decodeIfPresent(String.self, forKey: .editionName)
        physicalFormat = try container.decodeIfPresent(String.self, forKey: .physicalFormat)
        subjects = try container.decodeIfPresent([String].self, forKey: .subjects)
        fullTitle = try container.decodeIfPresent(String.self, forKey: .fullTitle)
        numberOfPages = try container.decodeIfPresent(Int.self, forKey: .numberOfPages)
        authors = OpenLibraryKey.decodeToArray(from: container, forKey: .authors)
        works = OpenLibraryKey.decodeToArray(from: container, forKey: .works)
        if let coverIds = try container.decodeIfPresent([Int].self, forKey: .covers) {
            covers = coverIds.map { OpenLibraryCoverImage(id: $0) }
        } else {
            covers = []
        }
    }
    
    public var workId: String {
        if let workId = works.first?.split(separator: "/").last {
            return String(workId)
        } else {
            return key
        }
    }
}

public struct OpenLibraryResponseLinks: Codable {
    public let selfLink: String
    public let next: String?
    
    public enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case next
    }
}

public struct OpenLibraryEditionResponse: Codable {
    public let links: OpenLibraryResponseLinks
    public let size: Int
    public let entries: [OpenLibraryEdition]
}

public struct OpenLibraryWorksResponse: Decodable {
    public let links: OpenLibraryResponseLinks
    public let size: Int
    public let entries: [OpenLibraryWork]
}

public struct OpenLibrarySearchResultDoc: IdentifiableFromKey {
    public let title: String
    public let key: String
    public let authorName: String?
    public let authorKey: String?
    public let cover: OpenLibraryCoverImage?
    
    enum CodingKeys: String, CodingKey {
        case title
        case key
        case coverId = "cover_i"
        case authorName = "author_name"
        case authorKey = "author_key"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        key = try container.decode(String.self, forKey: .key)
        authorName = try container.decodeIfPresent(String.self, forKey: .authorName)
        authorKey = try container.decodeIfPresent(String.self, forKey: .authorKey)
        if let coverId = try container.decodeIfPresent(Int.self, forKey: .coverId) {
            cover = OpenLibraryCoverImage(id: coverId)
        } else {
            cover = nil
        }
    }
}

public struct OpenLibrarySearchResponse: Decodable {
    public let numFound: Int
    public let start: Int
    public let numFoundExact: Bool
    public let offset: Int?
    public let docs: [OpenLibrarySearchResultDoc]
}

public struct OpenLibrarySearchQuery: StringKeyValueConvertible {
    public let q: String
    public var offset: Int = 0
    public var limit: Int = 100
    
    public func keyValues() -> [KeyValuePair<String>] {
        return [
            ("q", q),
            ("offset", String(offset)),
            ("limit", String(limit))
        ]
    }
}
