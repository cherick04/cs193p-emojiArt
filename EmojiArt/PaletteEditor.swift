//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by Erick Chacon on 10/7/22.
//

import SwiftUI

struct PaletteEditor: View {
    @State private var palette = PaletteStore(named: "Test").palette(at: 2)
    
    var body: some View {
        Form {
            TextField("Name", text: $palette.name)
        }
    }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditor()
            .previewLayout(.fixed(width: 300, height: 350))
    }
}
