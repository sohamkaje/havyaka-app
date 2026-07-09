import SwiftUI
import MapKit

// MARK: - Map View
struct MapView: View {
    @State private var selectedCategory: LocationCategory = .all
    @State private var selectedLocation: ConventionLocation? = nil
    @State private var showBlueprintSheet = false
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.7750, longitude: -88.2850),
            span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.22)
        )
    )

    let locations = ConventionData.locations

    var filteredLocations: [ConventionLocation] {
        selectedCategory == .all ? locations : locations.filter { $0.category == selectedCategory }
    }

    var body: some View {
        VStack(spacing: 0) {
            HAANavBar(title: "Locations", subtitle: "Hotels, venue & more")

            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(LocationCategory.allCases, id: \.self) { cat in
                        CategoryPill(
                            label: cat.rawValue,
                            icon: cat.systemIcon,
                            isSelected: selectedCategory == cat
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedCategory = cat
                                selectedLocation = nil
                                updateCamera()
                            }
                        }
                    }
                }
                .padding(.horizontal, HAA.Spacing.lg)
                .padding(.vertical, 10)
            }
            .background(Color.white)
            .overlay(Rectangle().fill(HAA.Colors.border).frame(height: 0.5), alignment: .bottom)

            // Live map
            mapSection

            // Venue blueprint banner
            venueBlueprintBanner

            // Location list
            locationList
        }
        .sheet(item: $selectedLocation) { loc in
            LocationDetailSheet(location: loc)
        }
        .sheet(isPresented: $showBlueprintSheet) {
            VenueBlueprintSheet()
        }
    }

    // MARK: - Map
    var mapSection: some View {
        Map(position: $cameraPosition) {
            ForEach(filteredLocations) { loc in
                Annotation(loc.name, coordinate: loc.coordinate) {
                    MapPinView(
                        location: loc,
                        isSelected: selectedLocation?.id == loc.id
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedLocation = loc
                            cameraPosition = .region(MKCoordinateRegion(
                                center: loc.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                            ))
                        }
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .frame(height: 210)
    }

    // MARK: - Venue Blueprint Banner
    var venueBlueprintBanner: some View {
        Button { showBlueprintSheet = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(HAA.Colors.orange.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "map.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(HAA.Colors.orange)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Rosary College Prep — Venue Guide")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(HAA.Colors.charcoal)
                    Text("HAA Convention 2026 · pinch to zoom")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(HAA.Colors.muted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(HAA.Colors.orange)
            }
            .padding(.horizontal, HAA.Spacing.lg)
            .padding(.vertical, 12)
            .background(HAA.Colors.orangeLight)
            .overlay(Rectangle().fill(HAA.Colors.orange.opacity(0.12)).frame(height: 0.5), alignment: .bottom)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Location List
    var locationList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(filteredLocations) { loc in
                    LocationRow(location: loc, isSelected: selectedLocation?.id == loc.id) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedLocation = loc
                            cameraPosition = .region(MKCoordinateRegion(
                                center: loc.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                            ))
                        }
                    }
                }
                Spacer().frame(height: 90)
            }
            .padding(.horizontal, HAA.Spacing.lg)
            .padding(.top, 12)
        }
        .background(HAA.Colors.cream)
    }

    func updateCamera() {
        if filteredLocations.count == 1 {
            cameraPosition = .region(MKCoordinateRegion(
                center: filteredLocations[0].coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            ))
        } else {
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 41.7750, longitude: -88.2850),
                span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.22)
            ))
        }
    }
}

// MARK: - Map Pin
struct MapPinView: View {
    let location: ConventionLocation
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                ZStack {
                    Circle()
                        .fill(location.accentColor)
                        .frame(width: isSelected ? 40 : 32, height: isSelected ? 40 : 32)
                        .shadow(color: location.accentColor.opacity(0.4), radius: isSelected ? 8 : 4)
                    if isSelected {
                        Circle().stroke(Color.white, lineWidth: 2.5).frame(width: 40, height: 40)
                    }
                    Image(systemName: location.icon)
                        .font(.system(size: isSelected ? 17 : 13, weight: .bold))
                        .foregroundColor(.white)
                }
                if isSelected {
                    Text(location.name)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(HAA.Colors.charcoal)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.1), radius: 3)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Location Row
struct LocationRow: View {
    let location: ConventionLocation
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(location.accentColor.opacity(0.12))
                        .frame(width: 46, height: 46)
                    Image(systemName: location.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(location.accentColor)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(location.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(HAA.Colors.charcoal)
                    Text(location.subtitle)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(location.accentColor)
                    if let dist = location.distanceNote {
                        Text(dist)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(HAA.Colors.muted)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(HAA.Colors.muted)
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: HAA.Radius.lg)
                    .stroke(isSelected ? location.accentColor.opacity(0.5) : HAA.Colors.border,
                            lineWidth: isSelected ? 1.5 : 0.5)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Location Detail Sheet
struct LocationDetailSheet: View {
    let location: ConventionLocation
    @Environment(\.dismiss) var dismiss

    @State private var mapPosition: MapCameraPosition

    init(location: ConventionLocation) {
        self.location = location
        _mapPosition = State(initialValue: .region(MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        )))
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Map(position: $mapPosition) {
                        Annotation(location.name, coordinate: location.coordinate) {
                            MapPinView(location: location, isSelected: true, onTap: {})
                        }
                    }
                    .mapStyle(.standard(elevation: .realistic))
                    .frame(height: 200)

                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(location.accentColor.opacity(0.12))
                                    .frame(width: 38, height: 38)
                                Image(systemName: location.icon)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(location.accentColor)
                            }
                            VStack(alignment: .leading, spacing: 1) {
                                Text(location.name)
                                    .font(HAA.Font.serif(18, weight: .bold))
                                    .foregroundColor(HAA.Colors.charcoal)
                                Text(location.subtitle)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(location.accentColor)
                            }
                        }

                        Divider()

                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(HAA.Colors.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Address")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundColor(HAA.Colors.muted)
                                    .tracking(0.5)
                                Text(location.address)
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(HAA.Colors.charcoal)
                            }
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Details")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(HAA.Colors.muted)
                                .tracking(0.5)
                            Text(location.detail)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(HAA.Colors.charcoal)
                                .lineSpacing(4)
                        }

                        Divider()

                        Button {
                            let placemark = MKPlacemark(coordinate: location.coordinate)
                            let mapItem = MKMapItem(placemark: placemark)
                            mapItem.name = location.name
                            mapItem.openInMaps(launchOptions: [
                                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                            ])
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                                    .font(.system(size: 18))
                                Text("Get Directions in Maps")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(HAA.Colors.orange)
                            .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(HAA.Spacing.lg)

                    Spacer(minLength: 40)
                }
            }
            .ignoresSafeArea(edges: .top)
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

// MARK: - Venue Blueprint Sheet
struct VenueBlueprintSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var steadyScale: CGFloat = 1.0

    private let baseWidth: CGFloat = 360

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                campusLegendRow
                Divider()

                ScrollView([.horizontal, .vertical], showsIndicators: true) {
                    Image("RosaryCampusMap")
                        .resizable()
                        .interpolation(.high)
                        .antialiased(true)
                        .scaledToFit()
                        .frame(width: baseWidth * scale)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(HAA.Colors.border, lineWidth: 1)
                        )
                        .padding(HAA.Spacing.lg)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let newScale = steadyScale * value
                                    scale = min(max(newScale, 1.0), 4.0)
                                }
                                .onEnded { _ in
                                    steadyScale = scale
                                }
                        )
                }
                .background(Color(hex: "#F5F2EC"))

                areaGuideSection
            }
            .navigationTitle("Venue Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if scale > 1.01 {
                        Button("Reset Zoom") {
                            withAnimation(.spring(response: 0.3)) {
                                scale = 1.0
                                steadyScale = 1.0
                            }
                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(HAA.Colors.orange)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(HAA.Colors.orange)
                }
            }
            .background(HAA.Colors.cream.ignoresSafeArea())
        }
    }

    private var campusLegendRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                legendChip(color: Color(hex: "#E57373"), label: "Dining")
                legendChip(color: Color(hex: "#81C784"), label: "Main Halls")
                legendChip(color: Color(hex: "#FFB74D"), label: "Jaatre")
                legendChip(color: Color(hex: "#CE93D8"), label: "Exhibition")
                legendChip(color: Color(hex: "#A5D6A7"), label: "Breakout")
                legendChip(color: Color(hex: "#C8E6C9"), label: "Practice", stroke: true)
                legendChip(color: Color(hex: "#388E3C"), label: "Green Rooms")
                legendChip(color: Color(hex: "#90CAF9"), label: "Dressing")
                legendChip(color: Color(hex: "#FFF9C4"), label: "Reserved", stroke: true)
                legendChip(color: Color(hex: "#F48FB1"), label: "Check-in")
                legendChip(color: Color(hex: "#F5F0E1"), label: "Hallways", stroke: true)
            }
            .padding(.horizontal, HAA.Spacing.lg)
            .padding(.vertical, 10)
        }
        .background(Color.white)
    }

    private func legendChip(color: Color, label: String, stroke: Bool = false) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 10, height: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(HAA.Colors.border, lineWidth: stroke ? 0.5 : 0)
                )
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(HAA.Colors.muted)
        }
    }

    private var areaGuideSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("VENUE AREAS")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(0.8)
                .foregroundColor(HAA.Colors.muted)
                .padding(.horizontal, HAA.Spacing.lg)
                .padding(.top, 12)
                .padding(.bottom, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(CampusArea.conventionAreas) { area in
                        HStack(alignment: .top, spacing: 12) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(area.color)
                                .frame(width: 14, height: 14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(HAA.Colors.border, lineWidth: area.needsBorder ? 0.5 : 0)
                                )
                                .padding(.top, 2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(area.label)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(HAA.Colors.charcoal)
                                Text(area.description)
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(HAA.Colors.muted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: HAA.Radius.md)
                                .stroke(HAA.Colors.border, lineWidth: 0.5)
                        )
                    }
                }
                .padding(.horizontal, HAA.Spacing.lg)
                .padding(.bottom, 16)
            }
            .frame(maxHeight: 240)
            .background(HAA.Colors.cream)
        }
        .overlay(Rectangle().fill(HAA.Colors.border).frame(height: 0.5), alignment: .top)
    }
}

// MARK: - Campus Area Guide
struct CampusArea: Identifiable {
    let id = UUID()
    let label: String
    let color: Color
    let description: String
    var needsBorder: Bool = false

    static let conventionAreas: [CampusArea] = [
        CampusArea(
            label: "Annapoorna Bhojana Shale (Gym)",
            color: Color(hex: "#E57373"),
            description: "Breakfast, lunch, and dinner."
        ),
        CampusArea(
            label: "Havya Paakashale (Cafeteria)",
            color: Color(hex: "#E57373"),
            description: "Tea and snacks."
        ),
        CampusArea(
            label: "Ahichhatra Auditorium",
            color: Color(hex: "#81C784"),
            description: "Main program hall for cultural programs and ceremonies."
        ),
        CampusArea(
            label: "Vishwamitra Kutira (Library)",
            color: Color(hex: "#81C784"),
            description: "Youth activity center."
        ),
        CampusArea(
            label: "Havya Kavya Yaga Shale (Courtyard)",
            color: Color(hex: "#81C784"),
            description: "Homa and rituals in the central courtyard."
        ),
        CampusArea(
            label: "Jaatre — Corridor Stalls",
            color: Color(hex: "#FFB74D"),
            description: "Exhibition and artisan market along the left corridor."
        ),
        CampusArea(
            label: "Exhibition & Sales",
            color: Color(hex: "#CE93D8"),
            description: "Angirasa Kutira (201) and Atri Kutira (203)."
        ),
        CampusArea(
            label: "Breakout Rooms",
            color: Color(hex: "#A5D6A7"),
            description: "Bharadvaja Kutira (204) and Jamadagni Kutira (206)."
        ),
        CampusArea(
            label: "Practice Rooms",
            color: Color(hex: "#C8E6C9"),
            description: "Open practice in rooms 105, 106, 107, 200, 202, and 207.",
            needsBorder: true
        ),
        CampusArea(
            label: "Green Rooms (Backstage)",
            color: Color(hex: "#388E3C"),
            description: "Orchestra Room (ladies), Drama Storage (mens), and Scene Storage (common)."
        ),
        CampusArea(
            label: "Dressing Rooms",
            color: Color(hex: "#90CAF9"),
            description: "Mens dressing (101, 103) and ladies dressing (102, 104)."
        ),
        CampusArea(
            label: "Reserved Rooms",
            color: Color(hex: "#FFF9C4"),
            description: "Gautama Kutira (205) — Yakshagana; Vasishta Kutira (209) — Youth Symphony; Kashyapa Kutira (208) — supply.",
            needsBorder: true
        ),
        CampusArea(
            label: "Check-in Desk",
            color: Color(hex: "#F48FB1"),
            description: "Convention registration at the main entrance."
        ),
        CampusArea(
            label: "Hallways",
            color: Color(hex: "#F5F0E1"),
            description: "Walking paths connecting all venue areas.",
            needsBorder: true
        ),
    ]
}
