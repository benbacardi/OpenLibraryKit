import XCTest
@testable import OpenLibraryKit

final class OpenLibraryKitTests: XCTestCase {
    
    func testSearch() async throws {
        let searchTerm = "day of fallen night"
        print("Searching for \(searchTerm)")
        var offset: Int = 0
        while true {
            if let response = await OpenLibrary.shared.search(searchTerm, offset: offset) {
                print("Results: \(response.numFound) (\(response.docs.count)) \(response.offset ?? 9999999)")
                if offset + response.docs.count >= response.numFound {
                    break
                } else {
                    offset += response.docs.count
                }
            } else {
                print("No results.")
                break
            }
        }
    }
    
//    func testAuthors() async throws {
//        let authorId = "OL34184A"
//        print("Searching for author \(authorId)")
//        if let author = await OpenLibrary.shared.getAuthor(withId: authorId) {
//            print("Author: \(author.name) (\(author.id))")
//            if let works = await OpenLibrary.shared.getWorks(forAuthorId: author.id) {
//                print("Works: \(works.size)")
//            } else {
//                print("No works found")
//            }
//        } else {
//            print("Author \(authorId) not found")
//        }
//    }
//    
    func testISBNSearch() async throws {
        let isbn = "9783608932645"
        print("Searching for ISBN \(isbn)")
        if let book = await OpenLibrary.shared.search(isbn: isbn) {
            print("Book: \(book.title) (\(book.id))")
            if let coverImage = book.covers.first {
                print("\(String(describing: coverImage.url(size: .large)))")
            }
            if let editions = await OpenLibrary.shared.getEditions(for: book) {
                print("Editions: \(editions.size)")
            } else {
                print("No editions fetched")
            }
        } else {
            print("ISBN \(isbn) not found")
        }
        
        print("Searching for ISBN 123")
        let _ = await OpenLibrary.shared.search(isbn: "123")
        
    }
//    
//    func testWorks() async throws {
//        let workId = "OL45804W"
//        if let work = await OpenLibrary.shared.getDetails(forWorkId: workId) {
//            print("Work: \(work.title)")
//            if let editions = await OpenLibrary.shared.getEditions(for: work) {
//                print("Editions: \(editions.size)")
//            } else {
//                print("No editions fetched")
//            }
//        }
//        print("Searching for work 1234")
//        let _ = await OpenLibrary.shared.getEditions(forWorkId: "1234")
//    }
//    
//    func testExample() throws {
//        // XCTest Documentation
//        // https://developer.apple.com/documentation/xctest
//
//        // Defining Test Cases and Test Methods
//        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
//    }
}
