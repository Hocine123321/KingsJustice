import SwiftUI

struct TitleView: View {
    let onBegin: () -> Void
    
    init(onBegin: @escaping () -> Void) {
        self.onBegin = onBegin
    }
    
    var body: some View {
        ZStack {
            BackgroundGradientView()
            
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 8) {
                    Text("A MEDIEVAL DUEL")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(5.0)
                        .foregroundColor(UITheme.textMuted)
                    
                    Text("The King's Justice")
                        .font(.system(size: 42, weight: .regular, design: .serif).italic())
                        .foregroundColor(UITheme.textCreamBright)
                        .shadow(color: UITheme.bloodRed.opacity(0.8), radius: 20)
                }
                
                Spacer()
                
                PillButton(title: "Begin", isPrimary: true, action: onBegin)
                    .padding(.bottom, 40)
            }
            .padding()
        }
    }
}
