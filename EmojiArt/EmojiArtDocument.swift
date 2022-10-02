//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Erick Chacon on 10/1/22.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    
    @Published private(set) var emojiArt: EmojiArtModel
    
    init() {
        emojiArt = EmojiArtModel()
        emojiArt.addEmoji(text: "😆", location: (-200, -100), size: 80)
        emojiArt.addEmoji(text: "😃", location: (200, 100), size: 80)
    }
    
    // MARK: - Convenience properties
    
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    // MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
    }
    
    func addEmoji(_ emoji: String, location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(text: emoji, location: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size += Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
}
