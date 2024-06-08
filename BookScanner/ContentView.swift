//
//  ContentView.swift
//  BookScanner
//
//  Created by Alex Wei on 4/28/24.
//

import SwiftUI
import CodeScanner

struct ContentView: View {
    @State private var isShowingScanner = false
    @State private var isFetchingBookDetails = false
    @State private var isShowingAlert = false
    @State private var alertTitle = ""
    
    @State private var shelf = Shelf()
    
    let client = OpenLibraryClient()
    
    func handleScan(result: Result<ScanResult, ScanError>) async {
        isShowingScanner = false

        switch result {
        case .success(let result):
            isFetchingBookDetails = true
            let success = await shelf.addBook(byISBN: result.string)
            if !success {
                alertTitle = "Could not find book details"
                isShowingAlert = true
            }
            isFetchingBookDetails = false

            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if isFetchingBookDetails {
                    ProgressView("Searching for book details...")
                }
                BookList(shelf: shelf)
            }
            .toolbar {
                Button("Camera", systemImage: "camera") {
                    isShowingScanner = true
                }
            }
            .navigationTitle("Books")
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.ean13], simulatedData: "Hello, world!") { result in
                    Task{
                        await handleScan(result: result)
                    }
                }
            }
            .alert(alertTitle, isPresented: $isShowingAlert) {
                
            }
        }
    }
}

#Preview {
    ContentView()
}
