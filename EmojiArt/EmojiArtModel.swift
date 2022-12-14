//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Erick Chacon on 10/1/22.
//

import Foundation

struct EmojiArtModel: Codable {
    var background = Background.blank
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable, Hashable, Codable {
        let text: String
        var x: Int // offset from the center
        var y: Int // offset from the center
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
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArtModel.self, from: json)
    }
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try EmojiArtModel(json: data)
    }
    
    
    func json() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    mutating func addEmoji(text: String, location: (x: Int, y: Int), size: Int) {
        uniqueEmojiID += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiID))
    }
    
    mutating func removeEmoji(_ emoji: Emoji) {
        emojis.remove(emoji)
    }
}
