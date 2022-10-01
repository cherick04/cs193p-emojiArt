//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Erick Chacon on 10/1/22.
//

import Foundation

struct EmojiArtModel {
    var background = Background.blank
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable, Hashable {
        let text: String
        var x: Int
        var y: Int
        var size: Int
        let id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    var uniqueEmojiID = 0
    
    init() {}
    
    mutating func addEmoji(text: String, location: (x: Int, y: Int), size: Int) {
        uniqueEmojiID += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiID))
    }
}
