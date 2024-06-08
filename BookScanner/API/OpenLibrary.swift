//
//  OpenLibrary.swift
//  BookScanner
//
//  Created by Alex Wei on 5/2/24.
//

import Foundation

struct OpenLibraryISBNResponse: Codable {
    let title: String
    let authors: [OpenLibraryISBNResponseAuthorEntry]?
    let covers: [Int]? // "id" in "https://covers.openlibrary.org/b/id/<id><S/M/L>.jpg"
}

struct OpenLibraryISBNResponseAuthorEntry: Codable {
    let key: String // "/authors/<author_id>"
    let name: String?
    let url: String?
}

struct OpenLibraryAuthorsResponse: Codable {
    let personalName: String
    let name: String
}

class OpenLibraryClient {
    private let baseURL = "https://openlibrary.org"
    private let baseCoversURL = "https://covers.openlibrary.org"
    
    static let instance = OpenLibraryClient()

    func getBook(byISBN isbn: String) async -> OpenLibraryISBNResponse? {
        let urlString = "\(baseURL)/isbn/\(isbn).json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return nil
        }
        
        guard let (data, _) = try? await URLSession.shared.data(from: url) else {
            print("Failed fetching data")
            return nil
        }

        guard let book = try? JSONDecoder().decode(OpenLibraryISBNResponse.self, from: data) else {
            print("Failed decoding response")
            return nil
        }
        
        return book
    }
    
    func getAuthor(byURLString urlString: String) async -> OpenLibraryAuthorsResponse? {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return nil
        }
        
        guard let (data, _) = try? await URLSession.shared.data(from: url) else {
            print("Failed fetching data")
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let author = try? decoder.decode(OpenLibraryAuthorsResponse.self, from: data) else {
            print("Failed decoding response")
            return nil
        }
        
        return author
    }
    
    func getAuthor(byKey key: String) async -> OpenLibraryAuthorsResponse? {
        let urlString = "\(baseURL)/\(key).json"
        return await getAuthor(byURLString: urlString)
    }
    
    func getAuthor(byOLID id: String) async -> OpenLibraryAuthorsResponse? {
        let urlString = "\(baseURL)/authors/\(id).json"
        return await getAuthor(byURLString: urlString)
    }
    
    func getCover(byOLID id: Int, size: String) async -> Data? {
        let urlString = "\(baseCoversURL)/b/id/\(id)-\(size).jpg"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return nil
        }
        
        guard let (data, _) = try? await URLSession.shared.data(from: url) else {
            print("Failed fetching data")
            return nil
        }
        
        return data
    }
        
    func getBookDetails(byISBN isbn: String) async -> Book? {
        // Get the book
        if let bookResponse = await getBook(byISBN: isbn) {
            // Get the authors' names
            var authors = [Author]()
            if let authorKeys = bookResponse.authors {
                for authorItem in authorKeys {
                    if let authorName = authorItem.name {
                        authors.append(Author(name: authorName))
                    } else if let authorResponse = await getAuthor(byKey: authorItem.key) {
                        authors.append(Author(name: authorResponse.personalName))
                    }
                }
            }
            
            // Get the covers
            var covers = [Cover]()
            for coverID in bookResponse.covers ?? [] {
                if let coverData = await getCover(byOLID: coverID, size: "L") {
                    covers.append(Cover(data: coverData))
                }
            }
            let book = Book(title: bookResponse.title, authors: authors, covers: covers)
            return book
        }
        
        return nil
    }
}
