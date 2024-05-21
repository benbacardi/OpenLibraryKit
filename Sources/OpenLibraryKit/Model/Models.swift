//
//  OpenLibraryBook.swift
//
//
//  Created by Ben Cardy on 17/05/2024.
//

import Foundation
import APIClient

struct OpenLibraryError: Codable, LocalizedError {
    let key: String
    let error: String
    
    var errorDescription: String? {
        error
    }
}

struct OpenLibraryLink: Codable {
    let title: String
    let url: URL
}

struct OpenLibraryCoverImage: Codable {
    let id: Int
    
    enum CoverImageSize: String {
        case small = "S"
        case medium = "M"
        case large = "L"
    }
    
    func url(size: CoverImageSize = .small) -> URL? {
        return URL(string: "\(OpenLibraryConstants.coverURL)id/\(id)-\(size.rawValue).jpg")
    }
}

/// https://openlibrary.org/authors/OL34184A.json
struct OpenLibraryAuthor: Codable, IdentifiableFromKey {
    let key: String
    let name: String
    let personalName: String?
    let alternateNames: [String]?
    let photos: [Int]?
    let bio: String?
    let links: [OpenLibraryLink]?
    
    enum CodingKeys: String, CodingKey {
        case key
        case name
        case personalName = "personal_name"
        case alternateNames = "alternate_names"
        case photos
        case bio
        case links
    }
    
    init(from decoder: Decoder) throws {
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
struct OpenLibraryWork: Decodable, IdentifiableFromKey {
    let title: String
    let key: String
    let authors: [String]
    let description: String?
    let covers: [OpenLibraryCoverImage]
    let subjectPlaces: [String]?
    let subjects: [String]?
    let subjectPeople: [String]?
    let subjectTimes: [String]?
    
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
    
    init(from decoder: Decoder) throws {
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
struct OpenLibraryEdition: Codable, IdentifiableFromKey {
    let title: String
    let key: String
    let authors: [String]
    let isbn13: [String]?
    let isbn10: [String]?
    let publishDate: String?
    let publishers: [String]?
    let editionName: String?
    let physicalFormat: String?
    let subjects: [String]?
    let fullTitle: String?
    let works: [String]
    let covers: [OpenLibraryCoverImage]
    let numberOfPages: Int?
    
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
    
    init(from decoder: Decoder) throws {
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
    
    var workId: String {
        if let workId = works.first?.split(separator: "/").last {
            return String(workId)
        } else {
            return key
        }
    }
}

struct OpenLibraryResponseLinks: Codable {
    let selfLink: String
    let next: String?
    
    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case next
    }
}

struct OpenLibraryEditionResponse: Codable {
    let links: OpenLibraryResponseLinks
    let size: Int
    let entries: [OpenLibraryEdition]
}

struct OpenLibraryWorksResponse: Decodable {
    let links: OpenLibraryResponseLinks
    let size: Int
    let entries: [OpenLibraryWork]
}

struct OpenLibrarySearchResultDoc: IdentifiableFromKey {
    let title: String
    let key: String
}

struct OpenLibrarySearchResponse: Decodable {
    let numFound: Int
    let start: Int
    let numFoundExact: Bool
    let offset: Int?
    let docs: [OpenLibrarySearchResultDoc]
}

struct OpenLibrarySearchQuery: StringKeyValueConvertible {
    let q: String
    var offset: Int = 0
    var limit: Int = 100
    
    func keyValues() -> [KeyValuePair<String>] {
        return [
            ("q", q),
            ("offset", String(offset)),
            ("limit", String(limit))
        ]
    }
}
