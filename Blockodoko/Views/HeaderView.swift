import SwiftUI

struct HeaderView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack {
            // Title & Coins
            HStack {
                Text("Blockodoko")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color(hex: "eee"))
                
                Spacer()
                
                HStack {
                    Text("💰")
                    Text("\(viewModel.coins)")
                        .font(.system(size: 14, weight: .bold))
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .background(Color(hex: "FFD740"))
                .foregroundColor(.black)
                .cornerRadius(20)
                .shadow(color: Color(hex: "FFD740").opacity(0.4), radius: 10)
            }
            .padding(.bottom, 10)
            
            // Seed & Difficulty Info
//            HStack {
//                Text("Seed: #\(viewModel.displayLevelSeed)")
//                    .font(.caption)
//                    .padding(4)
//                    .background(Color.white.opacity(0.1))
//                    .cornerRadius(4)
//                
//                Spacer()
                
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack {
//                        ForEach(Difficulty.allCases) { diff in
//                            Text(diff.displayName)
//                                .font(.caption)
//                                .padding(.horizontal, 8)
//                                .padding(.vertical, 4)
//                                .background(viewModel.difficulty == diff ? Color.blue : Color.white.opacity(0.1))
//                                .cornerRadius(12)
//                                .onTapGesture {
//                                    viewModel.startLevel(difficulty: diff)
//                                }
//                        }
//                    }
//                }
//            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
    }
}

#Preview {
    HeaderView(viewModel: .init())
}
