import SwiftUI

public struct ShopView<Engine: UIEngine>: View {
    @ObservedObject public var engine: Engine
    public let onBack: () -> Void
    
    public init(engine: Engine, onBack: @escaping () -> Void) {
        self.engine = engine
        self.onBack = onBack
    }
    
    public var body: some View {
        ZStack {
            BackgroundGradientView()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    HeaderKickView(kick: "Prepare for Battle", title: "Tonics & Draughts")
                        .padding(.top, 16)
                    
                    Text("GOLD AVAILABLE: \(engine.save.gold)")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(2.0)
                        .foregroundColor(UITheme.textGold)
                    
                    VStack(spacing: 12) {
                        ForEach(engine.tonicCatalog()) { item in
                            HStack(alignment: .center, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(item.name.uppercased())
                                            .font(.system(size: 14, weight: .bold))
                                            .tracking(1.5)
                                            .foregroundColor(UITheme.textCreamBright)
                                        
                                        Spacer()
                                        
                                        Text("\(item.price) GOLD")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(UITheme.textGold)
                                    }
                                    
                                    Text(item.desc)
                                        .font(.system(size: 11))
                                        .foregroundColor(UITheme.textCream.opacity(0.8))
                                    
                                    Text("Owned: \(item.owned)")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(UITheme.textMuted)
                                        .padding(.top, 2)
                                }
                                
                                Button(action: {
                                    _ = engine.buy(item.id)
                                    engine.saveAll()
                                }) {
                                    Text("BUY")
                                        .font(.system(size: 11, weight: .bold))
                                        .tracking(1.5)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(
                                            Capsule()
                                                .fill(engine.canBuy(item.id) ? UITheme.bloodRed : UITheme.bgNearBlack.opacity(0.5))
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(engine.canBuy(item.id) ? UITheme.brightRed : UITheme.borderCream.opacity(0.2), lineWidth: 1)
                                        )
                                }
                                .disabled(!engine.canBuy(item.id))
                                .buttonStyle(DriftButtonStyle())
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(UITheme.bgCard)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(UITheme.borderCream, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    PillButton(title: "Back", action: onBack)
                        .padding(.vertical, 16)
                }
            }
        }
    }
}
