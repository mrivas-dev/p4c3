import SwiftUI

/// Spacing scale from DESIGN.md (4 pt grid).
enum AppSpacing: CGFloat {
    case space1 = 4
    case space2 = 8
    case space3 = 12
    case space4 = 16
    case space5 = 20
    case space6 = 24
    case space8 = 32
    case space10 = 40
    case space12 = 48
    case space16 = 64

    var value: CGFloat { rawValue }
}

/// Corner radii from DESIGN.md.
enum AppRadius: CGFloat {
    case sm = 8
    case md = 12
    case lg = 16
    case xl = 20
    case full = 999

    var value: CGFloat { rawValue }
}

/// Layout primitives referenced in DESIGN.md patterns (avoid magic numbers in components).
enum AppLayout {
    /// Primary CTA height — DESIGN.md Touch Targets / Log Set button.
    static let primaryCTAHeight: CGFloat = 56

    /// 1 pt separators / card strokes (METRIC CARD pattern).
    static let hairlineBorderWidth: CGFloat = 1
}

extension Color {
    /// Palette — hex approximations from DESIGN.md § Color Palette (`Approx Hex` column).
    enum P4CE {
        static let bg = Color(hex: "#121418")
        static let surf = Color(hex: "#1C2026")
        static let surfHi = Color(hex: "#252B33")
        static let line = Color(hex: "#363D47")
        static let lineSoft = Color(hex: "#272E38")
        static let text = Color(hex: "#F7F7F0")
        static let textDim = Color(hex: "#C4C4B8")
        static let muted = Color(hex: "#6B7280")
        static let dim = Color(hex: "#3F4550")
        static let lime = Color(hex: "#D4F53C")
        static let limeDeep = Color(hex: "#9EBF1A")
        static let limeInk = Color(hex: "#1A2605")
        static let red = Color(hex: "#E05A3A")
        static let amber = Color(hex: "#F0C040")
        static let green = Color(hex: "#5DBF78")
    }
}

extension Color {
    /// Parses `#RRGGBB` / `#RRGGBBAA`; invalid strings fall back to clear (debug-visible).
    init(hex hexString: String) {
        var s = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard s.hasPrefix("#") else {
            self = .clear
            return
        }
        s.removeFirst()
        var value: UInt64 = 0
        guard Scanner(string: s).scanHexInt64(&value), s.count == 6 || s.count == 8 else {
            self = .clear
            return
        }
        let a, r, g, b: UInt64
        if s.count == 8 {
            a = (value >> 24) & 0xFF
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
            self.init(
                .sRGB,
                red: Double(r) / 255,
                green: Double(g) / 255,
                blue: Double(b) / 255,
                opacity: Double(a) / 255
            )
        } else {
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
            self.init(
                .sRGB,
                red: Double(r) / 255,
                green: Double(g) / 255,
                blue: Double(b) / 255,
                opacity: 1
            )
        }
    }

    init(hex numeric: UInt32, opacity: Double = 1) {
        let r = Double((numeric >> 16) & 0xFF) / 255
        let g = Double((numeric >> 8) & 0xFF) / 255
        let b = Double(numeric & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}
