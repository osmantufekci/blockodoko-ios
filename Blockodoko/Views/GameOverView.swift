//
//  GameOverView.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 10.12.2025.
//


import SwiftUI

struct GameOverView: View {
    var coins: Int = 0
    let onRestart: () -> Void
    let onUndo: () -> Void

    // Animasyon State
    @State private var isAnimating = false

    var eligibleToUsePowerUp: Bool {
        coins > JokerManager.standard.availableJokers.sorted(by: {$0.cost < $1.cost}).first?.cost ?? 0
    }

    var body: some View {
        ZStack {
            // 1. Arka Plan: Koyu ve Bulanık (Ümitsizlik havası ama şık)
            Rectangle()
                .fill(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.all)
                .overlay(Color.black.opacity(0.6))
            
            // 2. İçerik Kartı
            VStack(spacing: 25) {
                
                // İkon ve Başlık
                VStack(spacing: 10) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(
                            LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: .red.opacity(0.5), radius: 20, x: 0, y: 0)
                        .scaleEffect(isAnimating ? 1 : 0.5)
                        .rotationEffect(.degrees(isAnimating ? 0 : -45))
                    
                    Text("OUT OF MOVES")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                    
                    Text("Don't give up! Try again \(eligibleToUsePowerUp ? "or use a power-up" : "")")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Buton Grubu
                VStack(spacing: 15) {
                    
                    if eligibleToUsePowerUp {
                        Button(action: {
                            HapticManager.shared.buttonTap()
                            onUndo()
                        }) {
                            HStack {
                                Image(systemName: "bolt.heart")
                                Text("Use Power-up")
                            }
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }

                    // 2. Seçenek: Yeniden Başla (Restart)
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        onRestart()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("RESTART LEVEL")
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(30)
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
}

// Önizleme
#Preview {
    ZStack {
        Color.gray.ignoresSafeArea() // Arkadaki oyun alanı simülasyonu
        GameOverView(
            onRestart: { print("Restart") },
            onUndo: { print("Undo") }
        )
    }
}
