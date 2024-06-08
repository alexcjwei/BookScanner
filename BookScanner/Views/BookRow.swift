//
//  BookItemView.swift
//  BookScanner
//
//  Created by Alex Wei on 5/3/24.
//

import SwiftUI

struct BookRow: View {
    let book: Book
    
    var body: some View {
        HStack {
            Image(uiImage: book.image)
                .resizable()
                .scaledToFit()
                .containerRelativeFrame(.horizontal) { size, axis in
                    size * 0.2
                }
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                HStack {
                    ForEach(book.authors, id:\.name) {
                        Text($0.name)
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
}

#Preview {
    BookRow(book: Book(title: "Title", authors: [Author(name: "Author name")], covers: []))
}
