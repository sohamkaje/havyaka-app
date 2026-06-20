import SwiftUI

// MARK: - Offline Banner
struct OfflineBanner: View {
    var message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(HAA.Colors.orange)
            Text(message)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(HAA.Colors.charcoal)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HAA.Colors.orangeLight)
        .overlay(
            Rectangle()
                .fill(HAA.Colors.orange.opacity(0.2))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
}

// MARK: - Top Navigation Bar
struct HAANavBar: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(HAA.Colors.orange)
                    .frame(width: 34, height: 34)
                Text("HAA")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(HAA.Font.serif(16, weight: .semibold))
                    .foregroundColor(Color(hex: "#F5E8C0"))
                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(HAA.Colors.mutedLight)
                }
            }

            Spacer()
        }
        .padding(.horizontal, HAA.Spacing.lg)
        .padding(.vertical, 12)
        .background(HAA.Colors.charcoal)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var action: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(1.0)
                .foregroundColor(HAA.Colors.muted)

            Spacer()

            if let action = action {
                Button(action: { onAction?() }) {
                    Text(action)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(HAA.Colors.orange)
                }
            }
        }
        .padding(.horizontal, HAA.Spacing.lg)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
}

// MARK: - Tag Chip
struct EventTagChip: View {
    let tag: EventTag

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: tag.systemIcon)
                .font(.system(size: 9, weight: .semibold))
            Text(tag.rawValue)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .tracking(0.3)
        }
        .foregroundColor(tag.foregroundColor)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(tag.backgroundColor)
        .clipShape(Capsule())
    }
}

// MARK: - Highlight Pill
struct HighlightBadge: View {
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 8))
            Text("Highlight")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .tracking(0.3)
        }
        .foregroundColor(HAA.Colors.gold)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(HAA.Colors.gold.opacity(0.12))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(HAA.Colors.gold.opacity(0.3), lineWidth: 0.5))
    }
}

// MARK: - Location Category Pill
struct CategoryPill: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(label)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isSelected ? HAA.Colors.gold : HAA.Colors.muted)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(isSelected ? HAA.Colors.charcoal : Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(
                    isSelected ? Color.clear : HAA.Colors.border,
                    lineWidth: 0.5
                )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Orange CTA Button
struct HAAButton: View {
    let label: String
    let icon: String?
    let action: () -> Void
    var style: ButtonStyle = .filled

    enum ButtonStyle { case filled, outline }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                }
                Text(label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundColor(style == .filled ? .white : HAA.Colors.orange)
            .padding(.horizontal, 20)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .background(style == .filled ? HAA.Colors.orange : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: HAA.Radius.md)
                    .stroke(HAA.Colors.orange, lineWidth: style == .outline ? 1 : 0)
            )
        }
        .buttonStyle(.plain)
    }
}
