//
//  ConfettiView.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 11.12.2025.
//
import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50) { _ in
                ConfettiPiece()
            }
        }
        .onAppear { animate = true }
    }
}

struct ConfettiPiece: View {
    @State private var location: CGPoint = CGPoint(x: 0, y: -100)
    @State private var rotation: Double = 0
    @State private var color: Color = .random
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 10, height: 10)
            .position(location)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(
                    .interpolatingSpring(stiffness: 50, damping: 5)
                    .repeatForever(autoreverses: false)
                    .speed(Double.random(in: 0.5...1.5))
                    .delay(Double.random(in: 0...0.5))
                ) {
                    // Rastgele düşüş
                    location = CGPoint(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: UIScreen.main.bounds.height + 100
                    )
                    rotation = Double.random(in: 0...360)
                }
            }
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
