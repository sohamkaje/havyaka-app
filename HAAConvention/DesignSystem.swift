import SwiftUI

// MARK: - HAA Design System

enum HAA {

    // MARK: Colors
    enum Colors {
        static let charcoal      = Color(hex: "#1A1612")
        static let deepBrown     = Color(hex: "#2C1F0E")
        static let orange        = Color(hex: "#C8530A")
        static let orangeLight   = Color(hex: "#F5E8DF")
        static let gold          = Color(hex: "#B87D1A")
        static let goldLight     = Color(hex: "#FDF3E0")
        static let cream         = Color(hex: "#FDFAF6")
        static let warmWhite     = Color(hex: "#FFFFFF")
        static let border        = Color(hex: "#E8D8B0").opacity(0.35)
        static let borderStrong  = Color(hex: "#C8A860").opacity(0.3)
        static let muted         = Color(hex: "#6B5B4B")
        static let mutedLight    = Color(hex: "#A89070")

        // Tag backgrounds
        static let vedicBg       = Color(hex: "#FDF3E0")
        static let vedicFg       = Color(hex: "#8A5A10")
        static let culturalBg    = Color(hex: "#F5E8DF")
        static let culturalFg    = Color(hex: "#8A3A10")
        static let socialBg      = Color(hex: "#E1F5EE")
        static let socialFg      = Color(hex: "#0F5E3A")
        static let ceremonyBg    = Color(hex: "#E6F1FB")
        static let ceremonyFg    = Color(hex: "#185FA5")
    }

    // MARK: Typography
    enum Font {
        static func serif(_ size: CGFloat, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .custom("Georgia", size: size).weight(weight)
        }
        static func sans(_ size: CGFloat, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: .rounded)
        }
    }

    // MARK: Spacing
    enum Spacing {
        static let xs: CGFloat  = 4
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 12
        static let lg: CGFloat  = 16
        static let xl: CGFloat  = 20
        static let xxl: CGFloat = 28
    }

    // MARK: Corner Radius
    enum Radius {
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 12
        static let lg: CGFloat  = 16
        static let xl: CGFloat  = 20
        static let pill: CGFloat = 50
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - View Modifiers
struct HAACardStyle: ViewModifier {
    var padding: CGFloat = HAA.Spacing.lg
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(HAA.Colors.warmWhite)
            .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: HAA.Radius.lg)
                    .stroke(HAA.Colors.border, lineWidth: 0.5)
            )
    }
}

extension View {
    func haaCard(padding: CGFloat = HAA.Spacing.lg) -> some View {
        modifier(HAACardStyle(padding: padding))
    }
}
