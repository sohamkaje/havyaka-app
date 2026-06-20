import SwiftUI

enum InfoAccountSection: String, CaseIterable {
    case info = "Info"
    case account = "Account"
}

struct InfoAccountView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var network: NetworkMonitor
    @Binding var openAccountSection: Bool
    @State private var section: InfoAccountSection = .info

    var body: some View {
        VStack(spacing: 0) {
            HAANavBar(
                title: section == .info ? "Convention Info" : "My Account",
                subtitle: section == .info ? "Everything you need to know" : "Registration & profile"
            )

            sectionPicker

            if section == .account, !network.isConnected {
                OfflineBanner(
                    message: "No internet connection. Sign in, sign up, and check-in require service."
                )
            }

            switch section {
            case .info:
                InfoTabContent()
            case .account:
                if auth.isLoggedIn {
                    ProfileView(auth: auth)
                } else {
                    AccessView(auth: auth)
                }
            }
        }
        .onChange(of: openAccountSection) { _, shouldOpen in
            guard shouldOpen else { return }
            section = .account
            openAccountSection = false
        }
        .onAppear {
            guard openAccountSection else { return }
            section = .account
            openAccountSection = false
        }
    }

    private var sectionPicker: some View {
        HStack(spacing: 0) {
            ForEach(InfoAccountSection.allCases, id: \.self) { item in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        section = item
                    }
                } label: {
                    Text(item.rawValue)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(section == item ? .white : HAA.Colors.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            section == item
                                ? AnyShapeStyle(HAA.Colors.orange)
                                : AnyShapeStyle(Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: HAA.Radius.md)
                .stroke(HAA.Colors.border, lineWidth: 0.5)
        )
        .padding(.horizontal, HAA.Spacing.lg)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(HAA.Colors.border)
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
}

struct InfoTabContent: View {
    @State private var expandedCard: String? = "venue"

    var body: some View {
        ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    quickContactBar

                    VStack(spacing: 10) {
                        AccordionCard(
                            id: "venue",
                            icon: "mappin.and.ellipse",
                            title: "Venue & Dates",
                            accentColor: HAA.Colors.orange,
                            expandedCard: $expandedCard
                        ) {
                            venueContent
                        }

                        AccordionCard(
                            id: "committees",
                            icon: "person.3.fill",
                            title: "Organizing Committees",
                            accentColor: HAA.Colors.gold,
                            expandedCard: $expandedCard
                        ) {
                            committeesContent
                        }

                        AccordionCard(
                            id: "faq",
                            icon: "questionmark.circle.fill",
                            title: "FAQ & Need to Know",
                            accentColor: HAA.Colors.orange,
                            expandedCard: $expandedCard
                        ) {
                            faqContent
                        }

                        AccordionCard(
                            id: "sponsors",
                            icon: "star.circle.fill",
                            title: "Sponsors",
                            accentColor: HAA.Colors.gold,
                            expandedCard: $expandedCard
                        ) {
                            sponsorsContent
                        }

                        AccordionCard(
                            id: "about",
                            icon: "building.2.fill",
                            title: "About HAA",
                            accentColor: HAA.Colors.orange,
                            expandedCard: $expandedCard
                        ) {
                            aboutContent
                        }
                    }
                    .padding(.horizontal, HAA.Spacing.lg)
                    .padding(.top, 14)

                    Spacer().frame(height: 90)
                }
            }
            .background(HAA.Colors.cream)
    }

    // MARK: - Quick Contact Bar
    var quickContactBar: some View {
        HStack(spacing: 10) {
            Link(destination: URL(string: "https://haaconvention.org")!) {
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                        .font(.system(size: 13))
                    Text("Convention Site")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(HAA.Colors.orange)
                .clipShape(Capsule())
            }

            Link(destination: URL(string: "mailto:secretary@havyak.org")!) {
                HStack(spacing: 6) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 13))
                    Text("Email Us")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(HAA.Colors.orange)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(HAA.Colors.orangeLight)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(HAA.Colors.orange.opacity(0.3), lineWidth: 0.5))
            }

            Spacer()
        }
        .padding(.horizontal, HAA.Spacing.lg)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(Rectangle().fill(HAA.Colors.border).frame(height: 0.5), alignment: .bottom)
    }

    // MARK: - Accordion Contents

    var venueContent: some View {
        VStack(spacing: 12) {
            InfoRow(icon: "building.columns.fill", label: "Venue", value: "Rosary High School", color: HAA.Colors.orange)
            InfoRow(icon: "map.fill", label: "Address", value: "901 N Edgelawn Dr, Aurora, IL 60506", color: HAA.Colors.orange)
            InfoRow(icon: "calendar.badge.clock", label: "Dates", value: "July 3, 4 & 5, 2026", color: HAA.Colors.gold)
            InfoRow(icon: "moon.stars.fill", label: "Arrive", value: "Thursday evening, July 2", color: HAA.Colors.gold)
            InfoRow(icon: "envelope.fill", label: "Contact", value: "secretary@havyak.org", color: HAA.Colors.orange)

            Divider()

            HStack(spacing: 8) {
                Link(destination: URL(string: "https://haaconvention.org/registration/")!) {
                    HStack(spacing: 5) {
                        Image(systemName: "ticket.fill")
                            .font(.system(size: 12))
                        Text("Register")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(HAA.Colors.orange)
                    .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                }

                Link(destination: URL(string: "https://haaconvention.org/accommodations/")!) {
                    HStack(spacing: 5) {
                        Image(systemName: "bed.double.fill")
                            .font(.system(size: 12))
                        Text("Book Hotel")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(HAA.Colors.gold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(HAA.Colors.goldLight)
                    .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: HAA.Radius.md)
                            .stroke(HAA.Colors.gold.opacity(0.3), lineWidth: 0.5)
                    )
                }
            }
        }
    }

    var committeesContent: some View {
        VStack(spacing: 12) {
            let committees: [(String, String, Double)] = [
                ("Cultural Programs", "15 Chapters", 1.0),
                ("Vedic & Religious", "Core Team", 0.75),
                ("Youth Forum", "HAA Youth", 0.6),
                ("Havyasiri Publication", "Editorial", 0.5),
                ("Sponsorship & Finance", "Treasurer", 0.45),
                ("Accommodations", "Logistics", 0.4),
                ("Technology & App", "Tech Team", 0.35),
            ]

            ForEach(committees, id: \.0) { committee, count, fill in
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(committee)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(HAA.Colors.charcoal)
                        Spacer()
                        Text(count)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(HAA.Colors.muted)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(HAA.Colors.orangeLight)
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(HAA.Colors.orange)
                                .frame(width: geo.size.width * fill, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }

            Divider()

            Link(destination: URL(string: "https://haaconvention.org/haa2026-organizing-committee/")!) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                    Text("View Full Committee List")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundColor(HAA.Colors.orange)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(HAA.Colors.orangeLight)
                .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
            }
        }
    }

    var faqContent: some View {
        VStack(spacing: 12) {
            FAQItem(q: "What food is served?", a: "All meals are 100% vegetarian (Satvika). Traditional Havyaka cuisine is served including South Indian breakfasts, full rice lunches with sambar/rasam, and light dinners. Please inform organizers of any allergies.")
            FAQItem(q: "Which airport should I fly into?", a: "Chicago O'Hare (ORD) is ~40 min drive and preferred. Chicago Midway (MDW) is ~50 min. Rental cars and rideshares are available at both.")
            FAQItem(q: "What is the dress code?", a: "Traditional attire is encouraged for ceremonies and cultural events. Business casual is acceptable for daytime programs. A saree or kurta/dhoti is ideal for the opening ceremony and Yakshagana night.")
            FAQItem(q: "Is there parking at the venue?", a: "Yes, ample free parking is available on the Rosary High School campus.")
            FAQItem(q: "When does registration close?", a: "Early bird registration ended Feb 8, 2026. Standard registration is still open. Check haaconvention.org for current pricing.")
        }
    }

    var sponsorsContent: some View {
        VStack(spacing: 10) {
            Text("Become a sponsor and support the Havyaka community across the Americas. Various sponsorship tiers are available.")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(HAA.Colors.muted)
                .lineSpacing(3)

            Link(destination: URL(string: "https://haaconvention.org/sponsor/")!) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                    Text("View Sponsorship Packages")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(HAA.Colors.gold)
                .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
            }
        }
    }

    var aboutContent: some View {
        VStack(spacing: 12) {
            InfoRow(icon: "calendar.badge.clock", label: "Founded", value: "1982 · Registered in New Jersey, USA", color: HAA.Colors.gold)
            InfoRow(icon: "map.fill", label: "Chapters", value: "15 chapters across North America", color: HAA.Colors.orange)
            InfoRow(icon: "person.3.fill", label: "Members", value: "~500 at this convention", color: HAA.Colors.gold)
            InfoRow(icon: "heart.fill", label: "Mission", value: "Promoting Sanatana Dharma, Satvika lifestyle, and Havyaka cultural heritage", color: HAA.Colors.orange)

            Divider()

            Link(destination: URL(string: "https://www.havyak.org")!) {
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                        .font(.system(size: 12))
                    Text("Visit HAA Website")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundColor(HAA.Colors.orange)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(HAA.Colors.orangeLight)
                .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
            }
        }
    }
}

// MARK: - Accordion Card
struct AccordionCard<Content: View>: View {
    let id: String
    let icon: String
    let title: String
    let accentColor: Color
    @Binding var expandedCard: String?
    @ViewBuilder let content: () -> Content

    var isExpanded: Bool { expandedCard == id }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expandedCard = isExpanded ? nil : id
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 9)
                            .fill(accentColor.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(accentColor)
                    }

                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(HAA.Colors.charcoal)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(HAA.Colors.muted)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            // Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                        .padding(.horizontal, 14)
                    content()
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: HAA.Radius.lg)
                .stroke(isExpanded ? accentColor.opacity(0.3) : HAA.Colors.border, lineWidth: isExpanded ? 1 : 0.5)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isExpanded)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 20)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(0.6)
                    .foregroundColor(HAA.Colors.muted)
                Text(value)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(HAA.Colors.charcoal)
                    .lineSpacing(2)
            }
        }
    }
}

// MARK: - FAQ Item
struct FAQItem: View {
    let q: String
    let a: String
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3)) { expanded.toggle() }
            } label: {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(HAA.Colors.orange)
                        .rotationEffect(.degrees(expanded ? 90 : 0))
                        .padding(.top, 2)
                    Text(q)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(HAA.Colors.charcoal)
                        .multilineTextAlignment(.leading)
                }
            }
            .buttonStyle(.plain)

            if expanded {
                Text(a)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(HAA.Colors.muted)
                    .lineSpacing(3)
                    .padding(.top, 6)
                    .padding(.leading, 19)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Divider().padding(.top, 8)
        }
    }
}
