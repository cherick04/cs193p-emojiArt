//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Erick Chacon on 10/1/22.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let document = EmojiArtDocument()
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
