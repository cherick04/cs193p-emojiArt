//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Erick Chacon on 10/1/22.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    /// ViewModel
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument() )
    }
}
