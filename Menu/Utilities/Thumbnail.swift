import SwiftUI
import UIKit

func thumbnail(_ assetName: String, fallback systemName: String) -> Image {
    if let ui = UIImage(named: assetName) {
        return Image(uiImage: ui)
    } else {
        return Image(systemName: systemName)
    }
}
