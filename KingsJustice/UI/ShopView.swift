import SwiftUI

struct ShopView<Engine: UIEngine>: View {
    @ObservedObject var engine: Engine
    let onBack: () -> Void
    
    init(engine: Engine, onBack: @escaping () -> Void) {
        self.engine = engine
        self.onBack = onBack
    }
    
    private var styleName: String {
        return GameData.styles.first(where: { $0.id == engine.settings.style })?.name ?? "fighter"
    }

    @ViewBuilder
    private var armourySection: some View {
        if let armoury = engine as? ArmouryControlling {
            VStack(spacing: 10) {
                Text("THE ARMOURY")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(3.0)
                    .foregroundColor(UITheme.textGold)
                Text("Liveries for your \(styleName). Cosmetic only: no effect on a fight.")
                    .font(.system(size: 11))
                    .foregroundColor(UITheme.textCream.opacity(0.75))
                    .multilineTextAlignment(.center)
                ForEach(Armoury.all, id: \.id) { l in
                    liveryRow(l, armoury)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func liveryRow(_ l: Livery, _ armoury: ArmouryControlling) -> some View {
        let owned = Armoury.isOwned(engine.save, id: l.id)
        let worn = Armoury.equippedId(engine.save, style: engine.settings.style) == l.id
        let affordable = Armoury.canBuy(engine.save, id: l.id)
        return HStack(alignment: .center, spacing: 12) {
            HStack(spacing: -6) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color(hex: l.colors[i]))
                        .frame(width: 22, height: 22)
                        .overlay(Circle().stroke(Color(hex: l.trim), lineWidth: 1))
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(l.name.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(UITheme.textCreamBright)
                Text(owned ? "Owned" : "\(l.price) GOLD")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(owned ? UITheme.textMuted : UITheme.textGold)
            }
            Spacer()
            Button(action: {
                if !owned {
                    _ = armoury.buyLivery(l.id)
                } else if worn {
                    armoury.wearLivery(nil)
                } else {
                    armoury.wearLivery(l.id)
                }
                engine.saveAll()
            }) {
                Group {
                    if !owned {
                        Text("Buy")
                    } else if worn {
                        Text("Worn")
                    } else {
                        Text("Wear")
                    }
                }
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(worn ? UITheme.bgNearBlack : .white)
                .padding(.vertical, 7)
                .padding(.horizontal, 14)
                .background(Capsule().fill(worn ? UITheme.textGold : ((owned || affordable) ? UITheme.bloodRed : UITheme.bgNearBlack.opacity(0.5))))
                .overlay(Capsule().stroke((owned || affordable) ? UITheme.brightRed : UITheme.borderCream.opacity(0.2), lineWidth: 1))
            }
            .disabled(!owned && !affordable)
            .buttonStyle(DriftButtonStyle())
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 10).fill(UITheme.bgCard))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(worn ? UITheme.textGold : UITheme.borderCream, lineWidth: 1))
    }

    var body: some View {
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
                    
                    armourySection

                    PillButton(title: "Back", action: onBack)
                        .padding(.vertical, 16)
                }
            }
        }
    }
}
