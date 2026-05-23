import SwiftUI
import MapKit

// MARK: - Schedule Models

enum EventTag: String, CaseIterable {
    case vedic      = "Vedic"
    case cultural   = "Cultural"
    case social     = "Social"
    case ceremony   = "Ceremony"
    case meal       = "Meal"
    case concert    = "Concert"
    case meeting    = "Meeting"
    case youth      = "Youth"
    case sports     = "Sports"

    var backgroundColor: Color {
        switch self {
        case .vedic:    return HAA.Colors.vedicBg
        case .cultural: return HAA.Colors.culturalBg
        case .social:   return HAA.Colors.socialBg
        case .ceremony: return HAA.Colors.ceremonyBg
        case .meal:     return Color(hex: "#F1EFE8")
        case .concert:  return HAA.Colors.culturalBg
        case .meeting:  return HAA.Colors.ceremonyBg
        case .youth:    return Color(hex: "#E8F4FD")
        case .sports:   return Color(hex: "#E8F8F0")
        }
    }

    var foregroundColor: Color {
        switch self {
        case .vedic:    return HAA.Colors.vedicFg
        case .cultural: return HAA.Colors.culturalFg
        case .social:   return HAA.Colors.socialFg
        case .ceremony: return HAA.Colors.ceremonyFg
        case .meal:     return Color(hex: "#4A4030")
        case .concert:  return HAA.Colors.culturalFg
        case .meeting:  return HAA.Colors.ceremonyFg
        case .youth:    return Color(hex: "#1565A8")
        case .sports:   return Color(hex: "#166E3F")
        }
    }

    var systemIcon: String {
        switch self {
        case .vedic:    return "flame.fill"
        case .cultural: return "theatermasks.fill"
        case .social:   return "person.3.fill"
        case .ceremony: return "star.fill"
        case .meal:     return "fork.knife"
        case .concert:  return "music.note"
        case .meeting:  return "person.2.fill"
        case .youth:    return "figure.run"
        case .sports:   return "sportscourt.fill"
        }
    }
}

struct ScheduleEvent: Identifiable {
    let id = UUID()
    let time: String
    let title: String
    let kannada: String?
    let tag: EventTag
    let details: String
    let icon: String
    var isHighlight: Bool = false
}

struct ConventionDay: Identifiable {
    let id = UUID()
    let shortDay: String
    let fullDate: String
    let monthDay: String
    /// July calendar day number (2–5) for smart default selection
    let calendarDay: Int
    let events: [ScheduleEvent]
}

// MARK: - Location Models

enum LocationCategory: String, CaseIterable {
    case all      = "All"
    case venue    = "Venue"
    case hotels   = "Hotels"
    case food     = "Food & Grocery"

    var systemIcon: String {
        switch self {
        case .all:    return "map.fill"
        case .venue:  return "building.columns.fill"
        case .hotels: return "bed.double.fill"
        case .food:   return "leaf.fill"
        }
    }
}

struct ConventionLocation: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let address: String
    let category: LocationCategory
    let coordinate: CLLocationCoordinate2D
    let detail: String
    let accentColor: Color
    let icon: String
    var distanceNote: String? = nil
}

// MARK: - Photo Models

/// Event tags that can be applied to individual photos
enum PhotoEventTag: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case openingCeremony  = "Opening Ceremony"
    case concert          = "Concert"
    case yakshagana       = "Yakshagana"
    case vedicPrograms    = "Vedic Programs"
    case culturalPrograms = "Cultural Programs"
    case fashionShow      = "Fashion Show"
    case youthSymphony    = "Youth Symphony"
    case youthEvents      = "Youth Events"
    case socialHour       = "Social Hour"
    case meals            = "Meals"
    case general          = "General"

    var icon: String {
        switch self {
        case .openingCeremony:  return "flag.fill"
        case .concert:          return "music.mic"
        case .yakshagana:       return "theatermasks.fill"
        case .vedicPrograms:    return "flame.fill"
        case .culturalPrograms: return "theatermasks"
        case .fashionShow:      return "tshirt.fill"
        case .youthSymphony:    return "music.note.list"
        case .youthEvents:      return "figure.run"
        case .socialHour:       return "person.3.fill"
        case .meals:            return "fork.knife"
        case .general:          return "photo.fill"
        }
    }
}

struct ConventionPhoto: Identifiable {
    let id = UUID()
    let imageName: String   // SF Symbol placeholder; replace with real image asset/URL
    let caption: String
    let uploadedBy: String
    let day: String         // "July 2", "July 3", "July 4", "July 5"
    let eventTag: PhotoEventTag
    let accentColor: Color
}

/// Album filter shown in the photo tab bar
enum PhotoAlbum: String, CaseIterable {
    case all        = "All Photos"
    case day0       = "July 2"
    case day1       = "July 3"
    case day2       = "July 4"
    case day3       = "July 5"
}

// MARK: - Auth / Registration Models

struct AttendeeProfile: Identifiable, Codable {
    var id: String = UUID().uuidString
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var chapter: String = ""
    var registrationID: String = ""
    var membershipType: String = ""   // "Life", "Patron", "Regular"
    var dietaryNote: String = ""
    var isLoggedIn: Bool = false
}

// MARK: - Data Store

struct ConventionData {

    // MARK: Schedule
    static let days: [ConventionDay] = [
        ConventionDay(
            shortDay: "Thu", fullDate: "Thursday, July 2", monthDay: "Jul 2", calendarDay: 2,
            events: [
                ScheduleEvent(time: "2:00 PM", title: "Youth Pickleball Tournament", kannada: nil, tag: .sports,
                              details: "Kick off the convention early with the HAA Youth Committee's Pickleball Tournament! Open to all youth attendees. Brackets will be organized on-site. Prizes for top finishers.",
                              icon: "sportscourt.fill", isHighlight: true),
                ScheduleEvent(time: "5:00 PM", title: "Youth Social & Games", kannada: nil, tag: .youth,
                              details: "After the tournament, youth gather for casual games, introductions, and a chance to meet youth members from all 15 chapters across North America.",
                              icon: "figure.run"),
                ScheduleEvent(time: "6:30 PM", title: "Hotel Check-in & Welcome", kannada: "ಸ್ವಾಗತ", tag: .social,
                              details: "Check into your hotel and get settled. Volunteers will be at the lobby to welcome attendees and hand out convention packets.",
                              icon: "key.fill"),
                ScheduleEvent(time: "8:00 PM", title: "Program Rehearsals", kannada: "ಕಾರ್ಯಕ್ರಮಗಳ ಪೂರ್ವಾಭ್ಯಾಸ", tag: .cultural,
                              details: "Cultural program participants gather at the main hall for final rehearsals. All chapter performance teams are requested to be present.",
                              icon: "theatermasks.fill"),
                ScheduleEvent(time: "9:00 PM", title: "Light Dinner", kannada: "ಲಘು ಭೋಜನ", tag: .meal,
                              details: "Light vegetarian dinner for early arrivals. Menu includes South Indian snacks and refreshments.",
                              icon: "fork.knife"),
            ]
        ),
        ConventionDay(
            shortDay: "Fri", fullDate: "Friday, July 3", monthDay: "Jul 3", calendarDay: 3,
            events: [
                ScheduleEvent(time: "7:30 AM", title: "Breakfast", kannada: "ಉಪಾಹಾರ", tag: .meal,
                              details: "Vegetarian South Indian breakfast including idli, dosa, upma, sambar and chutney served at the main cafeteria.",
                              icon: "sunrise.fill"),
                ScheduleEvent(time: "11:00 AM", title: "Social Hour", kannada: "ಪರಿಚಯ, ಕುಶಲೋಪರಿ", tag: .social,
                              details: "An open networking hour for attendees to reconnect with old friends and make new ones. Refreshments will be served.",
                              icon: "person.3.fill"),
                ScheduleEvent(time: "12:30 PM", title: "Lunch", kannada: "ಭೋಜನ", tag: .meal,
                              details: "Full vegetarian lunch featuring traditional Havyaka cuisine — rice, sambar, rasam, palya, and payasam.",
                              icon: "fork.knife"),
                ScheduleEvent(time: "2:00 PM", title: "Grand Opening Parade & Ceremony", kannada: "ಭವ್ಯ ಮೆರವಣಿಗೆ · ಉದ್ಘಾಟನೆ", tag: .ceremony,
                              details: "The convention officially opens with a grand parade of all 15 HAA chapters, followed by the opening ceremony with speeches by distinguished guests including Dr. Giridhara Kaje and Vishweshwar Bhat.",
                              icon: "flag.fill", isHighlight: true),
                ScheduleEvent(time: "3:30 PM", title: "Havyasiri Release", kannada: "ಹವ್ಯಸಿರಿ ಬಿಡುಗಡೆ", tag: .ceremony,
                              details: "Launch of the Havyasiri publication — the HAA convention magazine featuring articles, essays, poetry, and community achievements from Havyaka members across the Americas.",
                              icon: "book.fill"),
                ScheduleEvent(time: "4:30 PM", title: "Chapter Cultural Programs", kannada: "ಸಾಂಸ್ಕೃತಿಕ ಕಾರ್ಯಕ್ರಮಗಳು", tag: .cultural,
                              details: "All 15 HAA chapters present their unique cultural performances — classical dance, Carnatic music, skits, and folk arts. Competition winners will be recognized.",
                              icon: "theatermasks.fill"),
                ScheduleEvent(time: "7:30 PM", title: "Dinner", kannada: "ಭೋಜನ", tag: .meal,
                              details: "Dinner is served. Traditional Havyaka feast with multiple courses.",
                              icon: "moon.stars.fill"),
                ScheduleEvent(time: "9:00 PM", title: "Anuradha Bhat — Musical Evening", kannada: "ಸಂಗೀತ ರಸಸಂಜೆ", tag: .concert,
                              details: "A captivating musical evening with celebrated playback singer Anuradha Bhat. Known across the Kannada film industry, she will perform a mix of devotional and film songs.",
                              icon: "music.mic", isHighlight: true),
            ]
        ),
        ConventionDay(
            shortDay: "Sat", fullDate: "Saturday, July 4", monthDay: "Jul 4", calendarDay: 4,
            events: [
                ScheduleEvent(time: "7:30 AM", title: "Breakfast", kannada: "ಉಪಾಹಾರ", tag: .meal,
                              details: "Vegetarian breakfast served at the main cafeteria.",
                              icon: "sunrise.fill"),
                ScheduleEvent(time: "10:00 AM", title: "Dance Drama", kannada: "ನೃತ್ಯ ರೂಪಕ", tag: .cultural,
                              details: "A full-length dance drama performance by well-known professional artists combining classical dance forms with Kannada storytelling.",
                              icon: "figure.dance"),
                ScheduleEvent(time: "12:30 PM", title: "Lunch & Youth Symphony", kannada: "ಭೋಜನ · ಯುವ ಸಂಗೀತ", tag: .meal,
                              details: "Lunch served alongside the Youth Symphony — young Havyaka musicians from across North America showcase their talent.",
                              icon: "music.note.list"),
                ScheduleEvent(time: "2:30 PM", title: "HAA Fashion Show", kannada: "ಫ್ಯಾಷನ್ ಶೋ", tag: .cultural,
                              details: "A vibrant showcase of traditional Havyaka attire and modern Indian fashion. Participants from all chapters walk the runway in sarees, dhotis, kurtas, and fusion wear. A celebration of cultural heritage through fashion.",
                              icon: "tshirt.fill", isHighlight: true),
                ScheduleEvent(time: "4:30 PM", title: "Chapter Cultural Programs", kannada: "ಸಾಂಸ್ಕೃತಿಕ ಕಾರ್ಯಕ್ರಮಗಳು", tag: .cultural,
                              details: "Continued chapter cultural performances. Open Dance Floor segment included for audience participation.",
                              icon: "theatermasks.fill"),
                ScheduleEvent(time: "5:30 PM", title: "Closing Ceremony", kannada: "ಸಮಾರೋಪ", tag: .ceremony,
                              details: "The 21st Biennial Convention closing ceremony. Awards, recognitions, and announcement of the next convention location.",
                              icon: "star.fill"),
                ScheduleEvent(time: "7:30 PM", title: "Dinner", kannada: "ಭೋಜನ", tag: .meal,
                              details: "Grand dinner before the Yakshagana performance.",
                              icon: "fork.knife"),
                ScheduleEvent(time: "9:00 PM", title: "Grand Yakshagana Performance", kannada: "ಅಮೋಘ ಯಕ್ಷಗಾನ ಪ್ರದರ್ಶನ", tag: .concert,
                              details: "The crown jewel of HAA 2026 — a full Yakshagana performance featuring Tenku Badagu Koodata by Yakshadhurva Patla Foundation Trust artists alongside Havyaka artists from the Americas. This traditional Karnataka art form combines dance, music, costume, and mythology.",
                              icon: "theatermasks.fill", isHighlight: true),
            ]
        ),
        ConventionDay(
            shortDay: "Sun", fullDate: "Sunday, July 5", monthDay: "Jul 5", calendarDay: 5,
            events: [
                ScheduleEvent(time: "8:00 AM", title: "Breakfast", kannada: "ಉಪಾಹಾರ", tag: .meal,
                              details: "Final morning breakfast at the convention.",
                              icon: "sunrise.fill"),
                ScheduleEvent(time: "9:30 AM", title: "HAA General Body Meeting", kannada: "ಸರ್ವ ಸದಸ್ಯ ಸಭೆ", tag: .meeting,
                              details: "The HAA General Body Meeting open to all life and patron members. Agenda includes financial review, committee reports, election of new officers, and planning for the next biennial convention.",
                              icon: "person.2.fill"),
            ]
        ),
    ]

    // MARK: Locations
    static let locations: [ConventionLocation] = [
        ConventionLocation(
            name: "Rosary High School",
            subtitle: "Convention Venue",
            address: "901 N Edgelawn Dr, Aurora, IL 60506",
            category: .venue,
            coordinate: CLLocationCoordinate2D(latitude: 41.7839, longitude: -88.3243),
            detail: "Home of the 21st Biennial HAA Convention. All cultural programs, ceremonies, and meals take place here. Ample parking is available on campus.",
            accentColor: HAA.Colors.orange,
            icon: "building.columns.fill",
            distanceNote: "Convention Venue"
        ),
        ConventionLocation(
            name: "Hampton Inn & Suites",
            subtitle: "from $139/night",
            address: "2423 W Orchard Rd, North Aurora, IL 60542",
            category: .hotels,
            coordinate: CLLocationCoordinate2D(latitude: 41.8060, longitude: -88.3350),
            detail: "Negotiated HAA group rate: $139/night (excl. taxes). Free cancellation before July 1, 2026 at 11:59 PM CDT. Located ~2 miles from the venue. Use the HAA group code when booking.",
            accentColor: HAA.Colors.gold,
            icon: "bed.double.fill",
            distanceNote: "~2 mi from venue"
        ),
        ConventionLocation(
            name: "Comfort Inn & Suites",
            subtitle: "from $110/night",
            address: "111 N. Farnsworth Ave, Aurora, IL 60505",
            category: .hotels,
            coordinate: CLLocationCoordinate2D(latitude: 41.7650, longitude: -88.2980),
            detail: "Negotiated HAA group rate: $110/night (excl. taxes). Free cancellation until June 24, 2026 at 4:00 PM CDT. Located ~3 miles from the venue. Book early — limited HAA block rooms available.",
            accentColor: HAA.Colors.gold,
            icon: "bed.double.fill",
            distanceNote: "~3 mi from venue"
        ),
        ConventionLocation(
            name: "Indian Vegetarian Restaurants",
            subtitle: "Aurora & Naperville area",
            address: "Multiple locations nearby",
            category: .food,
            coordinate: CLLocationCoordinate2D(latitude: 41.7850, longitude: -88.2800),
            detail: "Several South Indian and North Indian vegetarian restaurants are located within 10 minutes of the convention venue. A curated list will be shared in the convention packet.",
            accentColor: Color(hex: "#1D9E75"),
            icon: "leaf.fill",
            distanceNote: "Various locations"
        ),
        ConventionLocation(
            name: "Indian Grocery Stores",
            subtitle: "Patel Brothers & more",
            address: "Naperville & Schaumburg area",
            category: .food,
            coordinate: CLLocationCoordinate2D(latitude: 41.7980, longitude: -88.1620),
            detail: "Patel Brothers and other Indian grocery stores in the greater Chicagoland area are nearby. Patel Brothers Naperville is ~20 min from the venue.",
            accentColor: Color(hex: "#1D9E75"),
            icon: "cart.fill",
            distanceNote: "~15–20 min drive"
        ),
    ]

    // MARK: Photos (placeholder — replace imageName with real asset names / URLs)
    static let photos: [ConventionPhoto] = [
        ConventionPhoto(imageName: "flag.fill",        caption: "Opening parade",          uploadedBy: "DC Chapter",         day: "July 3", eventTag: .openingCeremony,  accentColor: HAA.Colors.orange),
        ConventionPhoto(imageName: "music.mic",        caption: "Anuradha Bhat concert",   uploadedBy: "NY Chapter",         day: "July 3", eventTag: .concert,          accentColor: HAA.Colors.orange),
        ConventionPhoto(imageName: "person.3.fill",    caption: "Social hour gathering",   uploadedBy: "Dallas Chapter",     day: "July 3", eventTag: .socialHour,       accentColor: Color(hex: "#1D9E75")),
        ConventionPhoto(imageName: "book.fill",        caption: "Havyasiri release",       uploadedBy: "Atlanta Chapter",    day: "July 3", eventTag: .openingCeremony,  accentColor: HAA.Colors.gold),
        ConventionPhoto(imageName: "theatermasks.fill",caption: "Yakshagana performance",  uploadedBy: "NorCal Chapter",     day: "July 4", eventTag: .yakshagana,       accentColor: HAA.Colors.gold),
        ConventionPhoto(imageName: "figure.dance",     caption: "Youth dance performance", uploadedBy: "SoCal Chapter",      day: "July 4", eventTag: .culturalPrograms, accentColor: HAA.Colors.gold),
        ConventionPhoto(imageName: "tshirt.fill",      caption: "Fashion show walk",       uploadedBy: "Midwest Chapter",    day: "July 4", eventTag: .fashionShow,      accentColor: HAA.Colors.orange),
        ConventionPhoto(imageName: "music.note.list",  caption: "Youth Symphony",          uploadedBy: "Chicago Chapter",    day: "July 4", eventTag: .youthSymphony,    accentColor: HAA.Colors.gold),
        ConventionPhoto(imageName: "star.fill",        caption: "Awards ceremony",         uploadedBy: "New England Chapter",day: "July 4", eventTag: .openingCeremony,  accentColor: HAA.Colors.orange),
        ConventionPhoto(imageName: "fork.knife",       caption: "Traditional feast",       uploadedBy: "Houston Chapter",    day: "July 3", eventTag: .meals,            accentColor: Color(hex: "#1D9E75")),
        ConventionPhoto(imageName: "person.2.fill",    caption: "General Body Meeting",    uploadedBy: "HAA Board",          day: "July 5", eventTag: .general,          accentColor: HAA.Colors.muted),
        ConventionPhoto(imageName: "sportscourt.fill", caption: "Pickleball tournament",   uploadedBy: "Youth Committee",    day: "July 2", eventTag: .youthEvents,      accentColor: Color(hex: "#166E3F")),
    ]
}
