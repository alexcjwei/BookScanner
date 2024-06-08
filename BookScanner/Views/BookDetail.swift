//
//  BookDetail.swift
//  BookScanner
//
//  Created by Alex Wei on 5/3/24.
//

import SwiftUI

struct BookDetail: View {
    let book: Book
    
    var body: some View {
        VStack {
            Image(uiImage: book.image)
                .resizable()
                .scaledToFit()
                .containerRelativeFrame(.vertical) { size, axis in
                    size * 0.2
                }
            if book.authors.count > 0 {
                HStack {
                    Text("by \(book.authors.map({$0.name}).joined(separator: ", "))")
                }
            }
            Spacer()
        }
        .navigationTitle(book.title)
    }
}

#Preview {
    BookDetail(book: Book(id: UUID(), title: "Hello", authors: [], covers: []))
}
