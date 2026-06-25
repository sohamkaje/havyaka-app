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
    var chapter: String? = nil
    var venue: String = "Main Auditorium"
    var isHighlight: Bool = false

    /// Full street address for the event detail sheet.
    var locationAddress: String {
        switch venue {
        case "Play N Thrive Club", "Play N Thrive Club, Naperville":
            return "808 S Route 59, Ste 120, Naperville, IL 60540"
        case "Chicago":
            return "Chicago, IL"
        default:
            return "Rosary College Prep · 901 N Edgelawn Dr, Aurora, IL 60506"
        }
    }

    var isOffSite: Bool {
        switch venue {
        case "Play N Thrive Club", "Play N Thrive Club, Naperville", "Chicago":
            return true
        default:
            return false
        }
    }
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
    case nearby   = "Nearby"
    case food     = "Food & Grocery"
    case sports   = "Sports & Activities"

    var systemIcon: String {
        switch self {
        case .all:    return "map.fill"
        case .venue:  return "building.columns.fill"
        case .hotels: return "bed.double.fill"
        case .nearby: return "star.circle.fill"
        case .food:   return "leaf.fill"
        case .sports: return "sportscourt.fill"
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

enum PhotoMediaType: String, Codable {
    case image
    case video
}

enum PhotosLimits {
    static let maxUploadBytes: Int64 = 45 * 1024 * 1024
    static var maxUploadMB: Int { Int(maxUploadBytes / (1024 * 1024)) }

    static func validateFileSize(_ byteCount: Int64) -> String? {
        guard byteCount > 0 else { return "Could not read the selected file." }
        guard byteCount <= maxUploadBytes else {
            let fileMB = Double(byteCount) / (1024 * 1024)
            return "This file is \(String(format: "%.1f", fileMB)) MB. The maximum allowed size is \(maxUploadMB) MB. Please choose a smaller photo or video."
        }
        return nil
    }

    static func formattedSize(_ byteCount: Int64) -> String {
        let mb = Double(byteCount) / (1024 * 1024)
        return mb >= 0.1 ? String(format: "%.1f MB", mb) : String(format: "%.0f KB", Double(byteCount) / 1024)
    }
}

// MARK: - Star Attractions

struct StarAttraction: Identifiable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let kannada: String?
    let iconColor: Color

    static let highlights: [StarAttraction] = [
        StarAttraction(
            id: "opening",
            icon: "flag.fill",
            title: "Grand Opening Ceremony",
            subtitle: "Opening procession & formal ceremony",
            description: "The official start of the 21st Biennial Convention with a festive procession, invocation dance, Veda Ghosha, addresses by HAA leadership and chief guest Vishweshwar Bhat, the HAA 10-year vision, sponsor recognition, and the convention theme song.",
            kannada: "ಉತ್ಸವ ಮೆರವಣಿಗೆ ಮತ್ತು ಉದ್ಘಾಟನಾ ಸಮಾರಂಭ",
            iconColor: HAA.Colors.orange
        ),
        StarAttraction(
            id: "anuradha",
            icon: "music.mic",
            title: "Anuradha Bhat & Team — Live",
            subtitle: "Celebrated playback singer from India",
            description: "A special musical night featuring celebrated playback singer Anuradha Bhat and accompanying artists from India — an evening of live Kannada film and classical favorites.",
            kannada: "ಅನುರಾಧಾ ಭಟ್ ಮತ್ತು ತಂಡದ ಸಂಗೀತ ರಾತ್ರಿ",
            iconColor: HAA.Colors.orange
        ),
        StarAttraction(
            id: "swami",
            icon: "hands.sparkles.fill",
            title: "Swami Aparajitananda",
            subtitle: "Intelligent Living & satsang",
            description: "Intelligent Living by Swami Aparajitananda on Saturday morning, followed by a breakout-room satsang and Q&A session for deeper reflection and community questions.",
            kannada: "ಸ್ವಾಮಿ ಅಪರಾಜಿತಾನಂದರ ಆಧ್ಯಾತ್ಮಿಕ ಪ್ರವಚನ",
            iconColor: HAA.Colors.gold
        ),
        StarAttraction(
            id: "maya-leela",
            icon: "figure.dance",
            title: "Maya Leela — Youth Dance Production",
            subtitle: "Dance drama by all chapter youth",
            description: "A grand dance drama production bringing together youth from HAA chapters across North America — a highlight of Friday evening's cultural program in the Main Auditorium.",
            kannada: "ಮಾಯಾ ಲೀಲಾ — ಯುವ ನೃತ್ಯ ನಿರೂಪಣೆ",
            iconColor: HAA.Colors.orange
        ),
        StarAttraction(
            id: "hima-maya",
            icon: "theatermasks.fill",
            title: "Hima Maya — Dance Production",
            subtitle: "Acharya Performing Arts Academy",
            description: "A dance drama production by Acharya Performing Arts Academy, presenting the Frozen story in Bharatanatyam dance drama style — one of Saturday morning's standout cultural performances.",
            kannada: "ಹಿಮ ಮಾಯಾ — ನೃತ್ಯ ನಿರೂಪಣೆ",
            iconColor: HAA.Colors.gold
        ),
        StarAttraction(
            id: "youth-symphony",
            icon: "music.note.list",
            title: "Youth Symphony",
            subtitle: "All-chapter youth musical presentation",
            description: "A special musical presentation bringing together talented youth from HAA chapters across North America — a showcase of the next generation of Havyaka artists.",
            kannada: "ಯುವ ಸಿಮ್ಫನಿ",
            iconColor: HAA.Colors.gold
        ),
        StarAttraction(
            id: "jugalbandi",
            icon: "music.quarternote.3",
            title: "Jugalbandi of Music",
            subtitle: "Vinayak Hegde & team",
            description: "A musical jugalbandi featuring Vinayak Hegde and team — an evening of collaborative classical performance and virtuoso interplay in the Main Auditorium.",
            kannada: "ಸಂಗೀತ ಜುಗಲ್ಬಂದಿ",
            iconColor: HAA.Colors.orange
        ),
        StarAttraction(
            id: "yakshagana",
            icon: "theatermasks.fill",
            title: "Yakshagana — Veeramani Kalaga",
            subtitle: "Led by Yakshamitra Toronto & US artists",
            description: "A grand Yakshagana performance of \"Veeramani Kalaga\" led by Yakshamitra Toronto and US artists — one of the convention's most anticipated cultural evenings.",
            kannada: "ಯಕ್ಷಗಾನ \"ವೀರಮಣಿ ಕಲಾಗ\"",
            iconColor: HAA.Colors.gold
        ),
    ]
}

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
    let id: String
    var mediaURL: String?
    let imageName: String
    let caption: String
    let uploadedBy: String
    let uploaderEmail: String
    let day: String
    let eventTag: PhotoEventTag
    let mediaType: PhotoMediaType
    let accentColor: Color

    init(
        id: String = UUID().uuidString,
        mediaURL: String? = nil,
        imageName: String = "photo.fill",
        caption: String,
        uploadedBy: String,
        uploaderEmail: String = "",
        day: String,
        eventTag: PhotoEventTag,
        mediaType: PhotoMediaType = .image,
        accentColor: Color = HAA.Colors.orange
    ) {
        self.id = id
        self.mediaURL = mediaURL
        self.imageName = imageName
        self.caption = caption
        self.uploadedBy = uploadedBy
        self.uploaderEmail = uploaderEmail
        self.day = day
        self.eventTag = eventTag
        self.mediaType = mediaType
        self.accentColor = accentColor
    }

    var isVideo: Bool { mediaType == .video }
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

enum AttendeeRole: String, Codable {
    case registrant
    case adult
    case kid

    var label: String {
        switch self {
        case .registrant: return "Primary Registrant"
        case .adult:      return "Adult Attendee"
        case .kid:        return "Youth Attendee"
        }
    }
}

struct AttendeeProfile: Identifiable, Codable {
    var id: String = UUID().uuidString
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var role: AttendeeRole = .registrant
    var registrationId: String = ""
    var registrationUuid: String = ""
    var hasCheckedIn: Bool = false
    var isLoggedIn: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, email, role, registrationId, hasCheckedIn, isLoggedIn
        case registrationUuid = "uuid"
    }

    init(
        id: String = UUID().uuidString,
        firstName: String = "",
        lastName: String = "",
        email: String = "",
        role: AttendeeRole = .registrant,
        registrationId: String = "",
        registrationUuid: String = "",
        hasCheckedIn: Bool = false,
        isLoggedIn: Bool = false
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.role = role
        self.registrationId = registrationId
        self.registrationUuid = registrationUuid
        self.hasCheckedIn = hasCheckedIn
        self.isLoggedIn = isLoggedIn
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? ""
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        role = try container.decodeIfPresent(AttendeeRole.self, forKey: .role) ?? .registrant
        registrationId = try container.decodeIfPresent(String.self, forKey: .registrationId) ?? ""
        registrationUuid = try container.decodeIfPresent(String.self, forKey: .registrationUuid) ?? ""
        hasCheckedIn = try container.decodeIfPresent(Bool.self, forKey: .hasCheckedIn) ?? false
        isLoggedIn = try container.decodeIfPresent(Bool.self, forKey: .isLoggedIn) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(role, forKey: .role)
        try container.encode(registrationId, forKey: .registrationId)
        try container.encode(registrationUuid, forKey: .registrationUuid)
        try container.encode(hasCheckedIn, forKey: .hasCheckedIn)
        try container.encode(isLoggedIn, forKey: .isLoggedIn)
    }

    var checkInURL: URL? {
        let uuid = registrationUuid.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !uuid.isEmpty else { return nil }
        var components = URLComponents(string: "https://haaconvention.org/registrations-report/")
        components?.queryItems = [URLQueryItem(name: "t", value: uuid)]
        return components?.url
    }
}

// MARK: - Data Store

struct ConventionData {

    // MARK: Schedule
    static let scheduleTitle = "HAA 21st Biennial Convention Schedule"
    static let scheduleSubtitle = "Chicago • July 2–5, 2026"
    static let scheduleTagline = "ನಮ್ಮ ಜನ · ನಮ್ಮತನ · ನಮ್ಮ ಧನ · ನಮ್ಮ ಋಣ"

    static let days: [ConventionDay] = [
        ConventionDay(
            shortDay: "Thu", fullDate: "Thursday, July 2", monthDay: "Jul 2", calendarDay: 2,
            events: thursdayEvents
        ),
        ConventionDay(
            shortDay: "Fri", fullDate: "Friday, July 3", monthDay: "Jul 3", calendarDay: 3,
            events: fridayEvents
        ),
        ConventionDay(
            shortDay: "Sat", fullDate: "Saturday, July 4", monthDay: "Jul 4", calendarDay: 4,
            events: saturdayEvents
        ),
        ConventionDay(
            shortDay: "Sun", fullDate: "Sunday, July 5", monthDay: "Jul 5", calendarDay: 5,
            events: sundayEvents
        ),
    ]

    // MARK: Locations
    static let locations: [ConventionLocation] = [
        ConventionLocation(
            name: "Rosary College Prep",
            subtitle: "Convention Venue",
            address: "901 N Edgelawn Dr, Aurora, IL 60506",
            category: .venue,
            coordinate: CLLocationCoordinate2D(latitude: 41.7753925, longitude: -88.3573770),
            detail: "Home of the 21st Biennial HAA Convention. All cultural programs, ceremonies, and meals take place here. Ample parking is available on campus.",
            accentColor: HAA.Colors.orange,
            icon: "building.columns.fill",
            distanceNote: "Convention Venue"
        ),
        ConventionLocation(
            name: "Hampton Inn & Suites",
            subtitle: "from $139/night",
            address: "2423 Bushwood Dr, Aurora, IL 60506",
            category: .hotels,
            coordinate: CLLocationCoordinate2D(latitude: 41.7916938, longitude: -88.3765416),
            detail: "Negotiated HAA group rate: $139/night (excl. taxes). Free cancellation before July 1, 2026 at 11:59 PM CDT. Located ~1.5 miles from the venue. Use the HAA group code when booking.",
            accentColor: HAA.Colors.gold,
            icon: "bed.double.fill",
            distanceNote: "~1.5 mi from venue"
        ),
        ConventionLocation(
            name: "Comfort Inn & Suites",
            subtitle: "from $110/night",
            address: "308 S Lincolnway St, North Aurora, IL 60542",
            category: .hotels,
            coordinate: CLLocationCoordinate2D(latitude: 41.7931408, longitude: -88.3265529),
            detail: "Comfort Inn & Suites North Aurora–Naperville. Negotiated HAA group rate: $110/night (excl. taxes). Free cancellation until June 24, 2026 at 4:00 PM CDT. Located ~2 miles from the venue.",
            accentColor: HAA.Colors.gold,
            icon: "bed.double.fill",
            distanceNote: "~2 mi from venue"
        ),
        ConventionLocation(
            name: "Aurora Balaji Temple",
            subtitle: "Sri Venkateswara Swami Temple",
            address: "1145 Sullivan Rd, Aurora, IL 60506",
            category: .nearby,
            coordinate: CLLocationCoordinate2D(latitude: 41.7884570, longitude: -88.3498930),
            detail: "Hindu temple dedicated to Lord Venkateswara (Balaji), about a mile from the convention venue. A popular place of worship and community gathering in the Aurora area.",
            accentColor: Color(hex: "#B45309"),
            icon: "building.columns.circle.fill",
            distanceNote: "~1 mi from venue"
        ),
        ConventionLocation(
            name: "Indian Vegetarian Restaurants",
            subtitle: "Idly Vada Bistro & more",
            address: "1521 Ogden Ave, Aurora, IL 60503",
            category: .food,
            coordinate: CLLocationCoordinate2D(latitude: 41.7206312, longitude: -88.2775297),
            detail: "Several South Indian and North Indian vegetarian restaurants are in the Aurora and Naperville area. Idly Vada Bistro on Ogden Ave is one popular option near the western suburbs.",
            accentColor: Color(hex: "#1D9E75"),
            icon: "leaf.fill",
            distanceNote: "~4 mi from venue"
        ),
        ConventionLocation(
            name: "Patel Brothers",
            subtitle: "Indian Grocery",
            address: "1568 W Ogden Ave, Naperville, IL 60540",
            category: .food,
            coordinate: CLLocationCoordinate2D(latitude: 41.7684335, longitude: -88.1843883),
            detail: "Patel Brothers Naperville carries Indian groceries, spices, snacks, and fresh produce. One of the closest major Indian grocery stores to the convention area.",
            accentColor: Color(hex: "#1D9E75"),
            icon: "cart.fill",
            distanceNote: "~9 mi from venue"
        ),
        ConventionLocation(
            name: "Play N Thrive Club",
            subtitle: "Youth Activity Venue",
            address: "808 S Route 59, Ste 120, Naperville, IL 60540",
            category: .sports,
            coordinate: CLLocationCoordinate2D(latitude: 41.7562474, longitude: -88.2023907),
            detail: "Youth activity on Thursday, July 2 (11:00 AM – 5:00 PM): pickleball, badminton, volleyball, and cricket nets. Food and drinks provided. Indoor acrylic courts, restrooms, water, lighting, and wheelchair accessible.",
            accentColor: Color(hex: "#166E3F"),
            icon: "sportscourt.fill",
            distanceNote: "Thu Jul 2 · 11:00 AM – 5:00 PM"
        ),
    ]
}
