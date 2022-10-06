//
//  EmojiArtModel.Background.swift
//  EmojiArt
//
//  Created by Erick Chacon on 10/1/22.
//

import Foundation

extension EmojiArtModel {
    
    enum Background: Equatable, Codable {
        case blank
        case url(URL)
        case imageData(Data)
        
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        var imageData: Data? {
            switch self {
            case .imageData(let imageData): return imageData
            default: return nil
            }
        }
    }
}
