//
//  BookListView.swift
//  BookScanner
//
//  Created by Alex Wei on 5/3/24.
//

import SwiftUI

struct BookList: View {
    var shelf: Shelf
    
    var body: some View {
        List {
            ForEach(shelf.books) {book in
                NavigationLink {
                    BookDetail(book: book)
                } label: {
                    BookRow(book: book)
                }
            }
            .onDelete(perform: shelf.remove)
        }
        .toolbar {
            EditButton()
        }
    }
}

#Preview {
    BookList(shelf: Shelf())
}
