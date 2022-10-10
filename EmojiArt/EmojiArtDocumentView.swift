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
    
    @State private var selectedEmojis = Set<EmojiArtModel.Emoji>()
    @State private var alertToShow: IdentifiableAlert?
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser(emojiFontSize: Constants.defaultEmojiFontSize)
        }
    }
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay {
                    OptionalImage(uiImage: document.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinates((0,0), in: geometry))
                }
                .gesture(doubleTapZoom(in: geometry.size).exclusively(before: singleTapDeselectAll()))
                
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(Constants.progressViewScale)
                } else {
                    if !selectedEmojis.isEmpty {
                        deleteButton
                            .position(x: geometry.size.center.x, y: 0)
                            .padding(.top, Constants.deleteButtonTopPadding)
                    }
                    // TODO: Fix repositioning and selection after performing gestures on selected emojis
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .padding(Constants.emojiPadding)
                            .border(borderStyle(for: emoji), width: Constants.emojiBorderWidth)
                            .font(.system(size: fontSize(for: emoji)))
                            .scaleEffect(zoomScale(for: emoji))
                            .position(position(for: emoji, in: geometry))
                            .gesture(singleTapSelection(for: emoji))
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
            .alert(item: $alertToShow) { alertToShow in
                alertToShow.alert()
            }
            .onChange(of: document.backgroundImageFetchStatus) { status in
                switch status {
                case .failed(let url):
                    showBackgroundImageFetchFailedAlert(url)
                default:
                    break
                }
            }
        }
    }
    
    private var deleteButton: some View {
        Button(role: .destructive, action: {
            selectedEmojis.forEach { emoji in
                document.removeEmoji(emoji)
            }
            selectedEmojis = []
        }, label: {
            Image(systemName: "trash.fill")
                .font(.largeTitle)
        })
    }
    
    // MARK: - Pan properties & methods
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    @GestureState private var selectedEmojisGesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        selectedEmojis.isEmpty
        ? DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { dragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (dragGestureValue.translation / zoomScale)
            }
        : DragGesture()
            .updating($selectedEmojisGesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { dragGestureValue in
                selectedEmojis.forEach { emoji in
                    let offset = dragGestureValue.translation / zoomScale
                    document.moveEmoji(emoji, by: offset)
                }
            }
    }
    
    // MARK: - Zoom properties & methods
    
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1

    private var zoomScale: CGFloat {
        selectedEmojis.isEmpty ? steadyStateZoomScale * gestureZoomScale : steadyStateZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { gestureScale in
                if selectedEmojis.isEmpty {
                    steadyStateZoomScale *= gestureScale
                } else {
                    selectedEmojis.forEach { emoji in
                        document.scaleEmoji(emoji, by: gestureScale)
                    }
                }
            }
    }
    
    private func zoomScale(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        selectedEmojis.contains(matching: emoji)
        ? steadyStateZoomScale * gestureZoomScale
        : zoomScale
    }
    
    private func doubleTapZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    // MARK: - Tap properties & methods
    
    private func singleTapSelection(for emoji: EmojiArtModel.Emoji) -> some Gesture {
        TapGesture()
            .onEnded {
                selectedEmojis.toggle(matching: emoji)
            }
    }
    
    private func singleTapDeselectAll() -> some Gesture {
        TapGesture()
            .onEnded {
                selectedEmojis = []
            }
    }
    
    // MARK: - Helpers
    
    private func borderStyle(for emoji: EmojiArtModel.Emoji) -> Color {
        selectedEmojis.contains(matching: emoji) ? .green : .clear
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        let location = selectedEmojis.contains(matching: emoji)
            ? temporaryLocation(for: emoji)
            : (emoji.x, emoji.y)
        return convertFromEmojiCoordinates(location, in: geometry)
    }
    
    private func temporaryLocation(for emoji: EmojiArtModel.Emoji) -> (Int, Int) {
        let x = emoji.x + Int(selectedEmojisGesturePanOffset.width)
        let y = emoji.y + Int(selectedEmojisGesturePanOffset.height)
        return (x, y)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
        )
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(.url(url.imageURL))
        }
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data))
                }
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(
                        String(emoji),
                        location: convertToEmojiCoordinates(location, in: geometry),
                        size: Constants.defaultEmojiFontSize / zoomScale
                    )
                }
            }
        }
        return found
    }
    
    private func showBackgroundImageFetchFailedAlert(_ url: URL) {
        alertToShow = IdentifiableAlert(id: "Fetch failed for: " + url.absoluteString, alert: {
                Alert(
                    title: Text("Background Image Fetch"),
                    message: Text("Couldn't load image from \(url)"),
                    dismissButton: .default(Text("OK"))
                )
            })
    }
    
    private struct Constants {
        static let defaultEmojiFontSize: CGFloat = 40
        static let progressViewScale: CGFloat = 5
        static let emojiPadding: CGFloat = 4
        static let emojiBorderWidth: CGFloat = 2
        static let deleteButtonTopPadding: CGFloat = 30
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument() )
    }
}
