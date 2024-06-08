//
//  Book.swift
//  BookScanner
//
//  Created by Alex Wei on 5/3/24.
//

import Foundation
import UIKit.UIImage

@Observable
class Shelf {
    var books = [Book]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(books) {
                UserDefaults.standard.setValue(encoded, forKey: "Books")
            }
        }
    }
    
    init() {
        if let savedBooks = UserDefaults.standard.data(forKey: "Books") {
            if let decodedBooks = try? JSONDecoder().decode([Book].self, from: savedBooks) {
                books = decodedBooks
                return
            }
        }
        
        books = []
    }
    
    func addBook(byISBN isbn: String) async -> Bool {
        if let book = await OpenLibraryClient.instance.getBookDetails(byISBN: isbn) {
            books.insert(book, at:0)
            return true
        }
        return false
    }
    
    func remove(at offsets: IndexSet) {
        books.remove(atOffsets: offsets)
    }
}

struct Book: Identifiable, Codable {
    var id = UUID()
    
    let title: String
    let authors: [Author]
    let covers: [Cover]
    
    var image: UIImage {
        if let coverData = covers.first?.data {
            if let image = UIImage(data: coverData) {
                return image
            }
        }
        return UIImage()
    }
}

struct Author: Codable {
    let name: String
}

struct Cover: Codable {
    let data: Data
}
