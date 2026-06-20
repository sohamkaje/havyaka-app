import SwiftUI

struct ScheduleView: View {
    @State private var selectedDayIndex: Int = ScheduleView.smartDefaultDay()
    @State private var selectedEvent: ScheduleEvent? = nil

    let days = ConventionData.days

    // Smart default: if today is Jul 2–5 pick that day, before → Jul 2, after → Jul 5
    static func smartDefaultDay() -> Int {
        let cal = Calendar.current
        let now = Date()
        let comps = cal.dateComponents(in: TimeZone(identifier: "America/Chicago")!, from: now)
        let month = comps.month ?? 0
        let day   = comps.day   ?? 0

        // Convention days: index 0 = Jul 2, 1 = Jul 3, 2 = Jul 4, 3 = Jul 5
        if month == 7 {
            switch day {
            case 2:  return 0
            case 3:  return 1
            case 4:  return 2
            case 5...: return 3
            default: return 0   // before Jul 2 in July → show Jul 2
            }
        } else if month > 7 {
            return 3            // past convention → Jul 5
        } else {
            return 0            // before July → show Jul 2 (pre-convention day)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HAANavBar(title: "Schedule", subtitle: "ಸಮಾವೇಶದ ಪಕ್ಷಿನೋಟ")
            daySelector

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    dayHeader
                    eventList
                    Spacer().frame(height: 90)
                }
            }
            .background(HAA.Colors.cream)
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailSheet(event: event)
        }
    }

    // MARK: - Day Selector
    var daySelector: some View {
        HStack(spacing: 0) {
            ForEach(days.indices, id: \.self) { idx in
                let day = days[idx]
                let isSelected = selectedDayIndex == idx

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedDayIndex = idx
                    }
                } label: {
                    VStack(spacing: 3) {
                        Text(day.shortDay)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Text(day.monthDay)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .tracking(0.3)
                    }
                    .foregroundColor(isSelected ? HAA.Colors.orange : HAA.Colors.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .overlay(
                        Rectangle()
                            .fill(isSelected ? HAA.Colors.orange : Color.clear)
                            .frame(height: 2.5)
                            .clipShape(Capsule()),
                        alignment: .bottom
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color.white)
        .overlay(
            Rectangle().fill(HAA.Colors.border).frame(height: 0.5),
            alignment: .bottom
        )
    }

    // MARK: - Day Header
    var dayHeader: some View {
        HStack {
            Text(days[selectedDayIndex].fullDate)
                .font(HAA.Font.serif(15, weight: .semibold))
                .foregroundColor(HAA.Colors.charcoal)
            Spacer()
            Text("\(days[selectedDayIndex].events.count) events")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(HAA.Colors.muted)
        }
        .padding(.horizontal, HAA.Spacing.lg)
        .padding(.vertical, 14)
        .background(Color.white)
        .overlay(
            Rectangle().fill(HAA.Colors.border).frame(height: 0.5),
            alignment: .bottom
        )
    }

    // MARK: - Event List
    var eventList: some View {
        LazyVStack(spacing: 10) {
            ForEach(days[selectedDayIndex].events) { event in
                EventCard(event: event) { selectedEvent = event }
            }
        }
        .padding(.horizontal, HAA.Spacing.lg)
        .padding(.top, 14)
    }
}

// MARK: - Event Card
struct EventCard: View {
    let event: ScheduleEvent
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 0) {

                // ── Left: time column ──
                VStack(alignment: .trailing) {
                    Text(event.time)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(HAA.Colors.muted)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .allowsTightening(true)
                }
                .frame(width: 52, alignment: .trailing)
                .padding(.top, 18)
                .padding(.trailing, 6)

                // ── Timeline dot ──
                VStack(spacing: 0) {
                    ZStack {
                        if event.isHighlight {
                            Circle()
                                .fill(HAA.Colors.gold)
                                .frame(width: 10, height: 10)
                            Circle()
                                .stroke(HAA.Colors.gold.opacity(0.4), lineWidth: 2)
                                .frame(width: 14, height: 14)
                        } else {
                            Circle()
                                .fill(HAA.Colors.orange.opacity(0.15))
                                .frame(width: 10, height: 10)
                            Circle()
                                .fill(HAA.Colors.orange)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.trailing, 6)

                // ── Right: card content ──
                VStack(alignment: .leading, spacing: 7) {
                    // Tag row
                    HStack(spacing: 6) {
                        if event.isHighlight { HighlightBadge() }
                        EventTagChip(tag: event.tag)
                    }

                    // Title
                    Text(event.title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(HAA.Colors.charcoal)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    // Kannada subtitle
                    if let kannada = event.kannada {
                        Text(kannada)
                            .font(HAA.Font.serif(12))
                            .foregroundColor(HAA.Colors.muted)
                    }

                    // Details preview
                    Text(event.details)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(HAA.Colors.muted)
                        .lineLimit(2)

                    // Tap hint
                    HStack {
                        Spacer()
                        HStack(spacing: 3) {
                            Text("Tap for details")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(HAA.Colors.orange)
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(HAA.Colors.orange)
                        }
                    }
                }
                .padding(.leading, 12)
                .padding(.top, 14)
                .padding(.trailing, 14)
                .padding(.bottom, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: HAA.Radius.lg)
                        .stroke(
                            event.isHighlight ? HAA.Colors.gold.opacity(0.4) : HAA.Colors.border,
                            lineWidth: event.isHighlight ? 1 : 0.5
                        )
                )
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Event Detail Sheet
struct EventDetailSheet: View {
    let event: ScheduleEvent
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Header band
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            EventTagChip(tag: event.tag)
                            if event.isHighlight { HighlightBadge() }
                        }
                        Text(event.title)
                            .font(HAA.Font.serif(22, weight: .bold))
                            .foregroundColor(HAA.Colors.charcoal)
                        if let kannada = event.kannada {
                            Text(kannada)
                                .font(HAA.Font.serif(15))
                                .foregroundColor(HAA.Colors.muted)
                        }
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 13))
                                .foregroundColor(HAA.Colors.gold)
                            Text(event.time)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(HAA.Colors.charcoal)
                        }
                    }
                    .padding(HAA.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(event.isHighlight ? HAA.Colors.goldLight : HAA.Colors.cream)

                    Divider()

                    VStack(alignment: .leading, spacing: 20) {
                        // Icon + description
                        HStack(alignment: .top, spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(event.tag.backgroundColor)
                                    .frame(width: 56, height: 56)
                                Image(systemName: event.icon)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(event.tag.foregroundColor)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("About this event")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .tracking(0.8)
                                    .foregroundColor(HAA.Colors.muted)
                                    .textCase(.uppercase)
                                Text(event.details)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(HAA.Colors.charcoal)
                                    .lineSpacing(4)
                            }
                        }

                        Divider()

                        // Venue
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Location")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .tracking(0.8)
                                .foregroundColor(HAA.Colors.muted)
                                .textCase(.uppercase)
                            HStack(spacing: 10) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(HAA.Colors.orange)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Rosary High School")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(HAA.Colors.charcoal)
                                    Text("901 N Edgelawn Dr, Aurora, IL 60506")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(HAA.Colors.muted)
                                }
                            }
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
