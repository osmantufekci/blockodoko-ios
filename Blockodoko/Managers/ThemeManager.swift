//
//  ThemeManager.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 13.12.2025.
//
import Combine

enum Texture {
    case wood, radial, classic

    var name: String {
        return switch self {
        case .wood: "woodTexture"
        case .radial: "radial"
        case .classic: "classic"
        }
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    @Published var currentStyle: Texture = .radial
}
