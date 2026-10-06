import SwiftUI

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
                        toggleRow(label: "IMPACT FLASHES", isOn: Binding(
                            get: { engine.settings.flash },
                            set: { engine.settings.flash = $0; engine.saveAll() }
                        ))
                        
                        toggleRow(label: "SHOW INPUT HINTS", isOn: Binding(
                            get: { engine.settings.guide },
                            set: { engine.settings.guide = $0; engine.saveAll() }
                        ))
                        
                        toggleRow(label: "VIBRATION (HAPTICS)", isOn: Binding(
                            get: { engine.settings.haptics },
                            set: { engine.settings.haptics = $0; engine.saveAll() }
                        ))
                        
                        toggleRow(label: "LEFT-HAND LAYOUT", isOn: Binding(
                            get: { engine.settings.leftHand },
                            set: { engine.settings.leftHand = $0; engine.saveAll() }
                        ))
                    }
                    .padding(.horizontal, 16)
                    
                    HStack(spacing: 10) {
                        PillButton(title: "Done", action: onBack)
                        PillButton(title: "Reset", action: {
                            engine.settings = GameSettings()
                            engine.saveAll()
                        })
                        PillButton(title: "Erase Save", action: {
                            showWipeAlert = true
                        })
                    }
                    .padding(.vertical, 16)
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
            Text(label.uppercased())
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
    
    private func toggleRow(label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(UITheme.textCream)
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: UITheme.brightRed))
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
