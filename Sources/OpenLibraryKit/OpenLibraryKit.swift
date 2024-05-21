// The Swift Programming Language
// https://docs.swift.org/swift-book

import APIClient

enum OpenLibraryConstants {
    static let baseGroup = Group(host: "openlibrary.org", path: "/")
    static let coverURL = "https://covers.openlibrary.org/b/"
}

enum OpenLibraryRequests {
    /// https://openlibrary.org/works/OL45804W.json
    /// https://openlibrary.org/works/OL45804W/editions.json
    static let worksGroup = OpenLibraryConstants.baseGroup.subgroup(path: "works/")
    
    static func worksRequest(for workId: String) -> Request<Nothing, OpenLibraryWork, OpenLibraryError> {
        worksGroup.request(path: "\(workId).json")
    }
    
    static func editionsRequest(for workId: String) -> Request<Nothing, OpenLibraryEditionResponse, OpenLibraryError> {
        worksGroup.subgroup(path: "\(workId)/").request(path: "editions.json")
    }
    
    /// https://openlibrary.org/isbn/123.json
    static let isbnGroup = OpenLibraryConstants.baseGroup.subgroup(path: "isbn/")
    
    static func isbnRequest(for isbn: String) -> Request<Nothing, OpenLibraryEdition, OpenLibraryError> {
        isbnGroup.request(path: "\(isbn).json")
    }
    
    /// https://openlibrary.org/authors/OL34184A.json
    /// https://openlibrary.org/authors/OL34184A/works.json
    static let authorsGroup = OpenLibraryConstants.baseGroup.subgroup(path: "authors/")
    
    static func authorsRequest(for authorId: String) -> Request<Nothing, OpenLibraryAuthor, OpenLibraryError> {
        authorsGroup.request(path: "\(authorId).json")
    }
    
    static func worksRequest(forAuthor authorId: String) -> Request<Nothing, OpenLibraryWorksResponse, OpenLibraryError> {
        authorsGroup.subgroup(path: "\(authorId)/").request(path: "works.json")
    }
    
    /// https://openlibrary.org/search.json?q=foo
    static func searchRequest() -> AdvancedRequest<Nothing, [String: String], OpenLibrarySearchQuery, OpenLibrarySearchResponse, OpenLibraryError> {
        OpenLibraryConstants.baseGroup.request(path: "search.json")
    }
    
}

public typealias OpenLibraryAPIError = APIClientError<OpenLibraryError>

public class OpenLibrary {
    
    public static let shared = OpenLibrary()
    
    private let client = APIClient()
    private var authorCache: [String: OpenLibraryAuthor] = [:]
    
    public func search(_ searchTerm: String, offset: Int = 0, limit: Int = 200) async -> OpenLibrarySearchResponse? {
        do {
            return try await client.make(request: OpenLibraryRequests.searchRequest(), queries: OpenLibrarySearchQuery(q: searchTerm, offset: offset, limit: limit)).data
        } catch let error as APIClientError<OpenLibraryError> {
            switch error {
            case .responseError(let olError, meta: let meta, underlyingError: let underlying):
                print("Term: \(searchTerm) OL: \(olError) Meta: \(meta.debugDescription) Underlying: \(underlying)")
            case .unexpectedResponseError(data: let data, meta: let meta, underlyingError: let underlying):
                print("Term: \(searchTerm) Data: \(String(data: data, encoding: .utf8).debugDescription) Meta: \(meta.debugDescription) Underlying: \(underlying)")
            case .otherError(let error):
                print("Term: \(searchTerm) Error in API response: \(error.localizedDescription)")
            }
        } catch {
            print("Term: \(searchTerm) Error while searching: \(error.localizedDescription)")
        }
        return nil
    }
    
    public func search(isbn: String) async -> OpenLibraryEdition? {
        do {
            return try await client.make(request: OpenLibraryRequests.isbnRequest(for: isbn)).data
        } catch let error as APIClientError<OpenLibraryError> {
            print("Error in API response: \(error.localizedDescription)")
        } catch {
            print("Error searching by ISBN: \(error.localizedDescription)")
        }
        return nil
    }
    
    public func getDetails(forWorkId workId: String) async -> OpenLibraryWork? {
        do {
            return try await client.make(request: OpenLibraryRequests.worksRequest(for: workId)).data
        } catch let error as APIClientError<OpenLibraryError> {
            print("Error in API response: \(error.localizedDescription)")
        } catch {
            print("Error fetching work: \(error.localizedDescription)")
        }
        return nil
    }
    
    public func getAuthor(withId authorId: String) async -> OpenLibraryAuthor? {
        if let author = authorCache[authorId] {
            return author
        }
        do {
            let author = try await client.make(request: OpenLibraryRequests.authorsRequest(for: authorId)).data
            authorCache[authorId] = author
            return author
        } catch let error as APIClientError<OpenLibraryError> {
            print("Error in API response: \(error.localizedDescription)")
        } catch {
            print("Error fetching author: \(error.localizedDescription)")
        }
        return nil
    }
    
    public func getWorks(forAuthorId authorId: String) async -> OpenLibraryWorksResponse? {
        do {
            return try await client.make(request: OpenLibraryRequests.worksRequest(forAuthor: authorId)).data
        } catch let error as APIClientError<OpenLibraryError> {
            print("Error in API response: \(error.localizedDescription)")
        } catch {
            print("Error fetching works: \(error.localizedDescription)")
        }
        return nil
    }
    
    public func getEditions(forWorkId workId: String) async -> OpenLibraryEditionResponse? {
        do {
            return try await client.make(request: OpenLibraryRequests.editionsRequest(for: workId)).data
        } catch let error as APIClientError<OpenLibraryError> {
            print("Error in API response: \(error.localizedDescription)")
        } catch {
            print("Error fetching editions: \(error.localizedDescription)")
        }
        return nil
    }
    
    public func getEditions(for work: OpenLibraryWork) async -> OpenLibraryEditionResponse? {
        return await getEditions(forWorkId: work.id)
    }
    
    public func getEditions(for edition: OpenLibraryEdition) async -> OpenLibraryEditionResponse? {
        return await getEditions(forWorkId: edition.workId)
    }
}
