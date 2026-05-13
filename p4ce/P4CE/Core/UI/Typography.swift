import SwiftUI
import UIKit

private enum FontResource {
    static let antonioPSName = "Antonio-Regular"
    static let geistPSName = "Geist-Regular"
    static let jetBrainsMonoPSName = "JetBrainsMono-Regular"
}

extension Font {
    /// DISPLAY — Antonio (`fontDisplay`). Falls back to system when the custom font isn’t registered.
    static func appDisplay(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        resolvedCustom(postScriptName: FontResource.antonioPSName, size: size, weight: weight, design: .default)
    }

    /// SANS — Geist (`fontSans`).
    static func appSans(size: CGFloat, weight: Font.Weight = .medium) -> Font {
        resolvedCustom(postScriptName: FontResource.geistPSName, size: size, weight: weight, design: .default)
    }

    /// MONO — JetBrains Mono (`fontMono`).
    static func appMono(size: CGFloat, weight: Font.Weight = .medium) -> Font {
        resolvedCustom(postScriptName: FontResource.jetBrainsMonoPSName, size: size, weight: weight, design: .monospaced)
    }

    /// Named styles derived from DESIGN.md typography table (midpoints where ranges given).
    enum Style {
        static let workoutHero = Font.appDisplay(size: 72, weight: .bold)
        static let heroSub = Font.appDisplay(size: 20, weight: .medium)
        static let statsLarge = Font.appDisplay(size: 27, weight: .semibold)
        static let ctaLabel = Font.appDisplay(size: 28, weight: .bold)
        static let sectionDate = Font.appSans(size: 18, weight: .semibold)
        static let sessionName = Font.appSans(size: 14, weight: .medium)
        static let metadataCaps = Font.appMono(size: 10, weight: .semibold)
        static let tagLabel = Font.appMono(size: 10, weight: .medium)
    }

    /// Letter spacing presets from DESIGN.md (values in pt; applied via `.tracking`).
    enum Tracking {
        static let workoutHero: CGFloat = -1.5
        static let heroSub: CGFloat = 0.4
        static let statsLarge: CGFloat = -0.5
        static let ctaLabel: CGFloat = 1.5
        static let sectionDate: CGFloat = -0.3
        static let metadataCapsLow: CGFloat = 1.3
        static let metadataCapsHigh: CGFloat = 1.6
        static let tagLabel: CGFloat = 1.6
        static let sectionHeaderCaps: CGFloat = 1.5
    }

    private static func resolvedCustom(
        postScriptName name: String,
        size: CGFloat,
        weight: Font.Weight,
        design fallbackDesign: Font.Design
    ) -> Font {
        if UIFont(name: name, size: size) != nil {
            return Font.custom(name, size: size).weight(weight)
        }
        return Font.system(size: size, weight: weight, design: fallbackDesign)
    }
}
