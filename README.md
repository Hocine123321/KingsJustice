# The King's Justice

A medieval rhythm duel, rewritten as a native iOS game (SwiftUI + Canvas).

## Build

Every push to `main` runs the **Build IPA** GitHub Action:
`Actions` tab, latest run, `KingsJustice-unsigned-ipa` artifact.

The IPA is unsigned. Sign and install it with your usual tool (AltStore, Sideloadly, TrollStore).

Local: `brew install xcodegen && xcodegen generate && open KingsJustice.xcodeproj`
