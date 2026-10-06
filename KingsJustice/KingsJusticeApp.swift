import SwiftUI

@main
struct KingsJusticeApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.black.ignoresSafeArea()
                Text("The King's Justice")
                    .font(.system(size: 34, weight: .regular, design: .serif).italic())
                    .foregroundColor(Color(red: 0.8, green: 0.75, blue: 0.65))
            }
            .statusBarHidden(true)
        }
    }
}
