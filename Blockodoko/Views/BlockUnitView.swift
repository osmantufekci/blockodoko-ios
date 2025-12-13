//
//  BlockUnitView.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 13.12.2025.
//
import SwiftUI

struct BlockUnitView: View {
    let color: String
    let size: CGFloat
    let isGhost: Bool

    @ObservedObject var theme = ThemeManager.shared

    var body: some View {
        ZStack {
            switch theme.currentStyle {
            case .classic:
                classicBody

            case .wood:
                woodBody

            case .radial:
                radialBody
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.15))
        .opacity(isGhost ? 0.4 : 1.0)
        .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 1)
    }

    // MARK: 1. KLASİK GÖRÜNÜM TASARIMI
    var classicBody: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.15)
                .fill(Color.from(string: color))

            RoundedRectangle(cornerRadius: size * 0.15)
                .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
        }
    }

    // MARK: 2. AHŞAP GÖRÜNÜM TASARIMI
    var woodBody: some View {
        ZStack {
            Image(theme.currentStyle.name)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipped()
                .colorMultiply(Color.from(string: color))

            RoundedRectangle(cornerRadius: size * 0.15)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
        }
    }

    var radialBody: some View {
        ZStack {
            Image(theme.currentStyle.name)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipped()
                .colorMultiply(Color.from(string: color))

            RoundedRectangle(cornerRadius: size * 0.15)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
        }
    }
}
