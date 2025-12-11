//
//  LevelProgressView.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 10.12.2025.
//
import SwiftUI

struct LevelProgressView: View {
    let placed: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 6) {

            Text("\(placed) / \(total) Blocks")
                .font(.caption)
                .foregroundColor(.gray)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Arkaplan
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    // Doluluk
                    Capsule()
                        .fill(Color.green) // İlerleme rengi
                        .frame(width: geo.size.width * (CGFloat(placed) / CGFloat(total)), height: 6)
                        .animation(.spring(), value: placed)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal)
    }
}
