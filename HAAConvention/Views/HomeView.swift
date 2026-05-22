import SwiftUI

struct HomeView: View {
    @State private var timeRemaining = TimeComponents()

    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            HAANavBar(
                title: "HAA Convention 2026",
                subtitle: "21st Biennial Havyaka Samagama"
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                    countdownBar
                    quickAccessGrid
                    starAttractions
                    Spacer().frame(height: 90)
                }
            }
            .background(HAA.Colors.cream)
        }
    }

    // MARK: - Hero
    var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            HAA.Colors.charcoal
                .overlay(diagonalPattern)

            VStack(alignment: .leading, spacing: 6) {
                Text("July 3 – 5, 2026  ·  Aurora, Illinois")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .tracking(0.8)
                    .foregroundColor(HAA.Colors.orange.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(HAA.Colors.orange.opacity(0.2))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(HAA.Colors.orange.opacity(0.4), lineWidth: 0.5))

                Text("ಹವ್ಯಕ ಸಮಾಗಮ")
                    .font(HAA.Font.serif(28, weight: .bold))
                    .foregroundColor(Color(hex: "#F5E8C0"))

                Text("ನಮ್ಮ ಜನ, ನಮ್ಮತನ, ನಮ್ಮ ಧನ, ನಮ್ಮ ಋಣ")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(HAA.Colors.mutedLight)

                HStack(spacing: 16) {
                    Label("Rosary High School", systemImage: "mappin.and.ellipse")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(HAA.Colors.mutedLight)
                    Label("~500 attendees", systemImage: "person.3.fill")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(HAA.Colors.mutedLight)
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, HAA.Spacing.lg)
            .padding(.vertical, 22)
        }
    }

    var diagonalPattern: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                ctx.stroke(
                    Path { path in
                        stride(from: -size.height, through: size.width + size.height, by: 22).forEach { x in
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x + size.height, y: size.height))
                        }
                    },
                    with: .color(Color(hex: "#C8A860").opacity(0.06)),
                    lineWidth: 1
                )
            }
        }
    }

    // MARK: - Countdown
    var countdownBar: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Convention starts in")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .tracking(0.5)
                    .foregroundColor(HAA.Colors.muted)
            }
            Spacer()
            HStack(spacing: 2) {
                countUnit(value: String(format: "%02d", timeRemaining.days), label: "days")
                colonSep
                countUnit(value: String(format: "%02d", timeRemaining.hours), label: "hrs")
                colonSep
                countUnit(value: String(format: "%02d", timeRemaining.minutes), label: "min")
            }
        }
        .padding(.horizontal, HAA.Spacing.lg)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(HAA.Colors.goldLight)
                .overlay(
                    Rectangle()
                        .fill(HAA.Colors.gold.opacity(0.15))
                        .frame(height: 0.5),
                    alignment: .bottom
                )
        )
        .onAppear { updateCountdown() }
        .onReceive(timer) { _ in updateCountdown() }
    }

    var colonSep: some View {
        Text(":")
            .font(.system(size: 18, weight: .bold, design: .monospaced))
            .foregroundColor(HAA.Colors.gold)
    }

    func countUnit(value: String, label: String) -> some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundColor(HAA.Colors.charcoal)
            Text(label)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .tracking(0.5)
                .foregroundColor(HAA.Colors.muted)
        }
        .frame(minWidth: 40)
    }

    // MARK: - Quick Access
    var quickAccessGrid: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Quick Access")

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                QuickCard(icon: "calendar.badge.clock", label: "Schedule", sub: "3-day full program", color: HAA.Colors.orange)
                QuickCard(icon: "map.fill", label: "Locations", sub: "Hotels & venue", color: HAA.Colors.gold)
                QuickCard(icon: "photo.stack.fill", label: "Photos", sub: "Share memories", color: HAA.Colors.orange)
                QuickCard(icon: "info.circle.fill", label: "Convention Info", sub: "Committees & FAQ", color: HAA.Colors.gold)
            }
            .padding(.horizontal, HAA.Spacing.lg)
        }
    }

    // MARK: - Star Attractions
    var starAttractions: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Star Attractions")

            VStack(spacing: 10) {
                AttractionCard(
                    icon: "theatermasks.fill",
                    title: "Grand Yakshagana",
                    subtitle: "July 4 · Tenku Badagu Koodata",
                    iconColor: HAA.Colors.gold
                )
                AttractionCard(
                    icon: "music.mic",
                    title: "Anuradha Bhat — Live",
                    subtitle: "July 3 · Musical Evening",
                    iconColor: HAA.Colors.orange
                )
                AttractionCard(
                    icon: "flame.fill",
                    title: "Vaidika Programs & Homa",
                    subtitle: "July 3 · Sacred morning rituals",
                    iconColor: HAA.Colors.vedicFg
                )
                AttractionCard(
                    icon: "waveform",
                    title: "Veda Ghosha",
                    subtitle: "July 4 · Students' Vedic recitation",
                    iconColor: HAA.Colors.gold
                )
            }
            .padding(.horizontal, HAA.Spacing.lg)
        }
    }

    func updateCountdown() {
        let target = conventionDate()
        let now = Date()
        let diff = target.timeIntervalSince(now)
        guard diff > 0 else { return }
        let totalMinutes = Int(diff / 60)
        let minutes = totalMinutes % 60
        let totalHours = totalMinutes / 60
        let hours = totalHours % 24
        let days = totalHours / 24
        timeRemaining = TimeComponents(days: days, hours: hours, minutes: minutes)
    }

    func conventionDate() -> Date {
        var comps = DateComponents()
        comps.year = 2026; comps.month = 7; comps.day = 3
        comps.hour = 9; comps.minute = 0
        comps.timeZone = TimeZone(identifier: "America/Chicago")
        return Calendar.current.date(from: comps) ?? Date()
    }
}

struct TimeComponents {
    var days: Int = 43
    var hours: Int = 12
    var minutes: Int = 0
}

// MARK: - Quick Card
struct QuickCard: View {
    let icon: String
    let label: String
    let sub: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(HAA.Colors.charcoal)
                Text(sub)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(HAA.Colors.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HAA.Spacing.lg)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: HAA.Radius.lg)
                .stroke(HAA.Colors.border, lineWidth: 0.5)
        )
        .overlay(
            color.opacity(0.06)
                .clipShape(
                    RoundedRectangle(cornerRadius: HAA.Radius.lg)
                ),
            alignment: .topTrailing
        )
    }
}

// MARK: - Attraction Card
struct AttractionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(HAA.Colors.charcoal)
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#F5E8C0"))
                Text(subtitle)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(HAA.Colors.mutedLight)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(HAA.Colors.mutedLight)
        }
        .padding(14)
        .background(HAA.Colors.charcoal)
        .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: HAA.Radius.lg)
                .stroke(HAA.Colors.gold.opacity(0.12), lineWidth: 0.5)
        )
    }
}
