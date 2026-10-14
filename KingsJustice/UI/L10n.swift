import Foundation

/// UI text goes through here so a translation can be dropped in without touching the views.
/// Add a language by copying Resources/en.lproj to <code>.lproj and translating the values.
enum L10n {
    /// Looks the English text up in Localizable.strings. If there is no entry, the English text itself is used.
    static func t(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
