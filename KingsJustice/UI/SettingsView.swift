import SwiftUI

/// One-line plain-language explanations shown under the settings toggles.
enum SettingsHints {
    static let flash = "A brief screen flash when a hit lands. Turn it off if it bothers your eyes."
    static let guide = "Shows on-screen hints about which move to use."
    static let haptics = "Vibration on hits and parries."
    static let leftHand = "Swaps the two button clusters for left-handed play."
    static let assist = "Widens YOUR timing windows by 25%. Enemies are not changed."
    static let reduceMotion = "Calms screen shake and camera zoom."
    static let colorSafe = "Uses colour-blind friendly ring colours."

    static var all: [String] { [flash, guide, haptics, leftHand, assist, reduceMotion, colorSafe] }
}

struct SettingsView<Engine: UIEngine>: View {
    @ObservedObject var engine: Engine
    let onBack: () -> Void
    
    @State private var showWipeAlert: Bool = false
    
    init(engine: Engine, onBack: @escaping () -> Void) {
        self.engine = engine
        self.onBack = onBack
    }
    
    private var difficultyOptions: [(key: String, label: String)] {
        [("easy", "Squire (easy)"), ("normal", "Knight (normal)"), ("hard", "Champion (hard)"), ("brutal", "Brutal")]
    }
    
    private var bloodOptions: [(key: Int, label: String)] {
        [(0, "Off"), (1, "Light"), (2, "Normal"), (3, "Heavy")]
    }
    
    private var qualityOptions: [(key: String, label: String)] {
        [("high", "High"), ("med", "Medium"), ("low", "Low (fastest)")]
    }
    
    private var versionText: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "THE KING'S JUSTICE  v\(version) (\(build))"
    }

    var body: some View {
        ZStack {
            BackgroundGradientView()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    HeaderKickView(kick: "Settings", title: "Tune the Fight")
                        .padding(.top, 16)
                    
                    VStack(spacing: 12) {
                        // Music volume
                        settingRow(label: "MUSIC VOLUME") {
                            Slider(
                                value: Binding(
                                    get: { engine.settings.music },
                                    set: { engine.settings.music = $0; engine.saveAll(); UIAudio.setVolumes(music: $0, sfx: engine.settings.sfx) }
                                ),
                                in: 0.0...1.0
                            )
                            .accentColor(UITheme.brightRed)
                        }
                        
                        // SFX volume
                        settingRow(label: "EFFECTS VOLUME") {
                            Slider(
                                value: Binding(
                                    get: { engine.settings.sfx },
                                    set: { engine.settings.sfx = $0; engine.saveAll(); UIAudio.setVolumes(music: engine.settings.music, sfx: $0) }
                                ),
                                in: 0.0...1.0
                            )
                            .accentColor(UITheme.brightRed)
                        }
                        
                        // Difficulty
                        settingRow(label: "DIFFICULTY") {
                            Picker("", selection: Binding(
                                get: { engine.settings.difficulty },
                                set: { engine.settings.difficulty = $0; engine.saveAll() }
                            )) {
                                ForEach(difficultyOptions, id: \.key) { opt in
                                    Text(opt.label).tag(opt.key)
                                }
                            }
                            .pickerStyle(.menu)
                            .accentColor(UITheme.textCreamBright)
                        }
                        
                        // Timing offset
                        settingRow(label: "TIMING OFFSET (\(Int(engine.settings.offset))MS)") {
                            Slider(
                                value: Binding(
                                    get: { engine.settings.offset },
                                    set: { engine.settings.offset = $0; engine.saveAll() }
                                ),
                                in: -150.0...250.0,
                                step: 5.0
                            )
                            .accentColor(UITheme.brightRed)
                        }
                        
                        // Screen shake
                        settingRow(label: "SCREEN SHAKE") {
                            Slider(
                                value: Binding(
                                    get: { engine.settings.shake },
                                    set: { engine.settings.shake = $0; engine.saveAll() }
                                ),
                                in: 0.0...1.5
                            )
                            .accentColor(UITheme.brightRed)
                        }
                        
                        // Gore level
                        settingRow(label: "GORE LEVEL") {
                            Picker("", selection: Binding(
                                get: { engine.settings.blood },
                                set: { engine.settings.blood = $0; engine.saveAll() }
                            )) {
                                ForEach(bloodOptions, id: \.key) { opt in
                                    Text(opt.label).tag(opt.key)
                                }
                            }
                            .pickerStyle(.menu)
                            .accentColor(UITheme.textCreamBright)
                        }
                        
                        // Quality
                        settingRow(label: "GRAPHICS QUALITY") {
                            Picker("", selection: Binding(
                                get: { engine.settings.quality },
                                set: { engine.settings.quality = $0; engine.saveAll() }
                            )) {
                                ForEach(qualityOptions, id: \.key) { opt in
                                    Text(opt.label).tag(opt.key)
                                }
                            }
                            .pickerStyle(.menu)
                            .accentColor(UITheme.textCreamBright)
                        }
                        
                        // Toggles
                        toggleRow(label: "IMPACT FLASHES", hint: SettingsHints.flash, isOn: Binding(
                            get: { engine.settings.flash },
                            set: { engine.settings.flash = $0; engine.saveAll() }
                        ))
                        
                        toggleRow(label: "SHOW INPUT HINTS", hint: SettingsHints.guide, isOn: Binding(
                            get: { engine.settings.guide },
                            set: { engine.settings.guide = $0; engine.saveAll() }
                        ))
                        
                        toggleRow(label: "VIBRATION (HAPTICS)", hint: SettingsHints.haptics, isOn: Binding(
                            get: { engine.settings.haptics },
                            set: { engine.settings.haptics = $0; engine.saveAll() }
                        ))
                        
                        toggleRow(label: "LEFT-HAND LAYOUT", hint: SettingsHints.leftHand, isOn: Binding(
                            get: { engine.settings.leftHand },
                            set: { engine.settings.leftHand = $0; engine.saveAll() }
                        ))

                        toggleRow(label: "TIMING ASSIST (WIDER WINDOWS)", hint: SettingsHints.assist, isOn: Binding(
                            get: { engine.settings.assist },
                            set: { engine.settings.assist = $0; engine.saveAll() }
                        ))

                        toggleRow(label: "REDUCE MOTION", hint: SettingsHints.reduceMotion, isOn: Binding(
                            get: { engine.settings.reduceMotion },
                            set: { engine.settings.reduceMotion = $0; engine.saveAll() }
                        ))

                        toggleRow(label: "COLOUR-BLIND COLOURS", hint: SettingsHints.colorSafe, isOn: Binding(
                            get: { engine.settings.colorSafe },
                            set: { engine.settings.colorSafe = $0; engine.saveAll() }
                        ))
                    }
                    .padding(.horizontal, 16)
                    
                    HStack(spacing: 10) {
                        PillButton(title: "Done", action: onBack)
                        PillButton(title: "Reset", action: {
                            // Reset is for settings only: keep the fighting style the player chose.
                            let keptStyle = engine.settings.style
                            engine.settings = GameSettings()
                            engine.settings.style = keptStyle
                            engine.saveAll()
                        })
                        PillButton(title: "Erase Save", action: {
                            showWipeAlert = true
                        })
                    }
                    .padding(.vertical, 16)

                    Text(versionText)
                        .font(.system(size: 10, weight: .regular))
                        .tracking(1.5)
                        .foregroundColor(UITheme.textCream.opacity(0.4))
                        .padding(.bottom, 12)
                }
            }
        }
        .alert(isPresented: $showWipeAlert) {
            Alert(
                title: Text("Erase Progress?"),
                message: Text("Erase gold, unlocks and best scores? This cannot be undone."),
                primaryButton: .destructive(Text("Erase")) {
                    engine.save = SaveData()
                    engine.saveAll()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func settingRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(L10n.t(label).uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(UITheme.textCream)
            
            Spacer()
            
            content()
                .frame(maxWidth: 160)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(UITheme.bgCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(UITheme.borderCream.opacity(0.16), lineWidth: 1)
        )
    }
    
    private func toggleRow(label: String, hint: String? = nil, isOn: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
        HStack {
            Text(L10n.t(label).uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(UITheme.textCream)
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: UITheme.brightRed))
        }
        if let hint = hint {
            Text(L10n.t(hint))
                .font(.system(size: 10))
                .foregroundColor(UITheme.textCream.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)
        }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(UITheme.bgCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(UITheme.borderCream.opacity(0.16), lineWidth: 1)
        )
    }
}
