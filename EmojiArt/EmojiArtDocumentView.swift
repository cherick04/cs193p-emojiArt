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
    let testEmojis = "😀😃😄😆🥹🥳🤩😅😂🤣🥲☺️😊"
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            palette
        }
    }
    
    var documentBody: some View {
        Color.yellow
    }
    
    var palette: some View {
        ScrollingEmojisView(emojis: testEmojis)
    }
}

struct ScrollingEmojisView: View {
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument() )
    }
}
