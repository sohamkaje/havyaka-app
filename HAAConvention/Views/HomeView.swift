import SwiftUI

struct HomeView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Binding var selectedTab: Int
    @Binding var moreSectionRequest: InfoAccountSection?
    @State private var timeRemaining = TimeComponents()
    @State private var conventionHasStarted = false
    @State private var selectedAttraction: StarAttraction? = nil
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
        .sheet(item: $selectedAttraction) { attraction in
            AttractionDetailSheet(attraction: attraction)
        }
    }

    // MARK: - Hero
    var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            HAA.Colors.charcoal.overlay(diagonalPattern)

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
                    Label("Rosary College Prep", systemImage: "mappin.and.ellipse")
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
        GeometryReader { _ in
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

    // MARK: - Countdown (seconds-level, fires every 1s)
    var countdownBar: some View {
        HStack(spacing: 0) {
            if conventionHasStarted {
                Text("Convention has started!")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(HAA.Colors.charcoal)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Convention starts in")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .tracking(0.5)
                        .foregroundColor(HAA.Colors.muted)
                }
                Spacer()
                HStack(spacing: 2) {
                    countUnit(value: String(format: "%02d", timeRemaining.days),    label: "days")
                    colonSep
                    countUnit(value: String(format: "%02d", timeRemaining.hours),   label: "hrs")
                    colonSep
                    countUnit(value: String(format: "%02d", timeRemaining.minutes), label: "min")
                    colonSep
                    countUnit(value: String(format: "%02d", timeRemaining.seconds), label: "sec")
                }
            }
        }
        .padding(.horizontal, HAA.Spacing.lg)
        .padding(.vertical, 14)
        .background(
            HAA.Colors.goldLight
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
            .font(.system(size: 16, weight: .bold, design: .monospaced))
            .foregroundColor(HAA.Colors.gold)
    }

    func countUnit(value: String, label: String) -> some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(HAA.Colors.charcoal)
            Text(label)
                .font(.system(size: 8, weight: .semibold, design: .rounded))
                .tracking(0.4)
                .foregroundColor(HAA.Colors.muted)
        }
        .frame(minWidth: 32)
    }

    // MARK: - Quick Access
    var quickAccessGrid: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Quick Access")

            if !auth.isLoggedIn {
                Button {
                    moreSectionRequest = .account
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 4
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Log in here")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(HAA.Colors.orange)
                    .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, HAA.Spacing.lg)
                .padding(.bottom, 12)
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                QuickCard(icon: "calendar.badge.clock", label: "Schedule", sub: "3-day full program", color: HAA.Colors.orange) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 1 }
                }
                QuickCard(icon: "map.fill", label: "Locations", sub: "Hotels & venue", color: HAA.Colors.gold) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 2 }
                }
                QuickCard(icon: "photo.stack.fill", label: "Photos", sub: "Share memories", color: HAA.Colors.orange) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 3 }
                }
                QuickCard(icon: "info.circle.fill", label: "Convention Info", sub: "Committees & FAQ", color: HAA.Colors.gold) {
                    moreSectionRequest = .info
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 4 }
                }
            }
            .padding(.horizontal, HAA.Spacing.lg)
        }
    }

    // MARK: - Star Attractions (chronological order, updated list)
    var starAttractions: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Star Attractions")

            VStack(spacing: 10) {
                ForEach(StarAttraction.highlights) { attraction in
                    AttractionCard(attraction: attraction) {
                        selectedAttraction = attraction
                    }
                }
            }
            .padding(.horizontal, HAA.Spacing.lg)
        }
    }

    // MARK: - Countdown logic
    func updateCountdown() {
        let target = conventionDate()
        let diff = target.timeIntervalSince(Date())
        guard diff > 0 else {
            timeRemaining = TimeComponents(days: 0, hours: 0, minutes: 0, seconds: 0)
            conventionHasStarted = true
            return
        }
        conventionHasStarted = false
        let total   = Int(diff)
        let seconds = total % 60
        let minutes = (total / 60) % 60
        let hours   = (total / 3600) % 24
        let days    = total / 86400
        timeRemaining = TimeComponents(days: days, hours: hours, minutes: minutes, seconds: seconds)
    }

    func conventionDate() -> Date {
        var c = DateComponents()
        c.year = 2026; c.month = 7; c.day = 3
        c.hour = 9; c.minute = 0; c.second = 0
        c.timeZone = TimeZone(identifier: "America/Chicago")
        return Calendar.current.date(from: c) ?? Date()
    }
}

struct TimeComponents {
    var days: Int = 43
    var hours: Int = 12
    var minutes: Int = 0
    var seconds: Int = 0
}

// MARK: - Quick Card
struct QuickCard: View {
    let icon: String
    let label: String
    let sub: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Attraction Card
struct AttractionCard: View {
    let attraction: StarAttraction
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(HAA.Colors.charcoal)
                        .frame(width: 50, height: 50)
                    Image(systemName: attraction.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(attraction.iconColor)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(attraction.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#F5E8C0"))
                        .multilineTextAlignment(.leading)
                    Text(attraction.subtitle)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(HAA.Colors.mutedLight)
                        .multilineTextAlignment(.leading)
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
        .buttonStyle(.plain)
    }
}

// MARK: - Attraction Detail Sheet
struct AttractionDetailSheet: View {
    let attraction: StarAttraction
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        HighlightBadge()
                        Text(attraction.title)
                            .font(HAA.Font.serif(22, weight: .bold))
                            .foregroundColor(HAA.Colors.charcoal)
                        if let kannada = attraction.kannada {
                            Text(kannada)
                                .font(HAA.Font.serif(15))
                                .foregroundColor(HAA.Colors.muted)
                        }
                        Text(attraction.subtitle)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(HAA.Colors.orange)
                    }
                    .padding(HAA.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(HAA.Colors.goldLight)

                    Divider()

                    HStack(alignment: .top, spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(HAA.Colors.charcoal)
                                .frame(width: 56, height: 56)
                            Image(systemName: attraction.icon)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(attraction.iconColor)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("What to Expect")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .tracking(0.8)
                                .foregroundColor(HAA.Colors.muted)
                                .textCase(.uppercase)
                            Text(attraction.description)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(HAA.Colors.charcoal)
                                .lineSpacing(4)
                        }
                    }
                    .padding(HAA.Spacing.lg)

                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(HAA.Colors.orange)
                }
            }
            .background(HAA.Colors.cream.ignoresSafeArea())
        }
    }
}
