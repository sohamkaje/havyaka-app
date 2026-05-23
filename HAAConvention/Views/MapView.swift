import SwiftUI
import MapKit

// MARK: - Map View
struct MapView: View {
    @State private var selectedCategory: LocationCategory = .all
    @State private var selectedLocation: ConventionLocation? = nil
    @State private var showBlueprintSheet = false
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.7850, longitude: -88.3100),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
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
                    Text("Rosary High School — Venue Map")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(HAA.Colors.charcoal)
                    Text("See which rooms host each event & program")
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
                center: CLLocationCoordinate2D(latitude: 41.7850, longitude: -88.3100),
                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
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
    @State private var selectedFloor = 0
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    let floors = ["Ground Floor", "Upper Field"]

    // Rooms per floor: (label, color, sfSymbol, description, x, y, w, h) — all in a 320×420 canvas
    let groundRooms: [BlueprintRoom] = [
        BlueprintRoom(label: "Main Auditorium",  color: Color(hex: "#C8530A"), icon: "theatermasks.fill",   desc: "Cultural programs, Yakshagana, Concert",      x: 10,  y: 10,  w: 200, h: 110),
        BlueprintRoom(label: "Cafeteria",        color: Color(hex: "#1D9E75"), icon: "fork.knife",          desc: "All meals served here",                       x: 10,  y: 130, w: 130, h: 80),
        BlueprintRoom(label: "Prayer Hall",      color: Color(hex: "#B87D1A"), icon: "flame.fill",          desc: "Vedic programs, Homa, Veda Ghosha",           x: 220, y: 10,  w: 90,  h: 80),
        BlueprintRoom(label: "Registration",     color: Color(hex: "#185FA5"), icon: "ticket.fill",         desc: "Convention check-in & packets",               x: 220, y: 100, w: 90,  h: 60),
        BlueprintRoom(label: "Green Room",       color: Color(hex: "#6B5B4B"), icon: "theatermasks",        desc: "Performers & artists backstage area",         x: 150, y: 130, w: 80,  h: 80),
        BlueprintRoom(label: "Info Desk",        color: Color(hex: "#185FA5"), icon: "info.circle.fill",    desc: "Volunteer info and help desk",                x: 220, y: 170, w: 90,  h: 40),
        BlueprintRoom(label: "Restrooms",        color: Color(hex: "#9E9E9E"), icon: "figure.stand",        desc: "Restrooms — Ground level",                    x: 10,  y: 220, w: 60,  h: 50),
        BlueprintRoom(label: "First Aid",        color: Color(hex: "#E53935"), icon: "cross.fill",          desc: "First aid station — staffed at all times",    x: 80,  y: 220, w: 60,  h: 50),
        BlueprintRoom(label: "Vendor Stalls",    color: Color(hex: "#B87D1A"), icon: "bag.fill",            desc: "Book stalls, CDs, traditional items",         x: 150, y: 220, w: 160, h: 50),
        BlueprintRoom(label: "Kids Zone",        color: Color(hex: "#9C27B0"), icon: "figure.and.child.holdinghands", desc: "Supervised play area for children", x: 10, y: 280, w: 100, h: 60),
        BlueprintRoom(label: "Parking",          color: Color(hex: "#546E7A"), icon: "car.fill",            desc: "Free parking on campus",                      x: 10,  y: 350, w: 300, h: 50),
    ]

    let upperRooms: [BlueprintRoom] = [
        BlueprintRoom(label: "Gymnasium",        color: Color(hex: "#166E3F"), icon: "sportscourt.fill",    desc: "Youth events, pickleball, open floor dance",  x: 10,  y: 10,  w: 200, h: 120),
        BlueprintRoom(label: "Classroom A",      color: Color(hex: "#185FA5"), icon: "person.3.fill",       desc: "Committee meetings & breakout sessions",      x: 220, y: 10,  w: 90,  h: 55),
        BlueprintRoom(label: "Classroom B",      color: Color(hex: "#185FA5"), icon: "book.fill",           desc: "Youth activities & HAA General Body Meeting", x: 220, y: 75,  w: 90,  h: 55),
        BlueprintRoom(label: "Fashion Runway",   color: Color(hex: "#C8530A"), icon: "tshirt.fill",         desc: "Fashion show runway & backstage",             x: 10,  y: 140, w: 200, h: 80),
        BlueprintRoom(label: "Sponsors Lounge",  color: Color(hex: "#B87D1A"), icon: "star.fill",           desc: "Sponsor recognition & VIP lounge",            x: 220, y: 140, w: 90,  h: 80),
        BlueprintRoom(label: "Photo Booth",      color: Color(hex: "#9C27B0"), icon: "camera.fill",         desc: "Convention photo booth — take your pic!",     x: 10,  y: 230, w: 90,  h: 60),
        BlueprintRoom(label: "Restrooms",        color: Color(hex: "#9E9E9E"), icon: "figure.stand",        desc: "Restrooms — Upper level",                     x: 110, y: 230, w: 60,  h: 60),
    ]

    var currentRooms: [BlueprintRoom] { selectedFloor == 0 ? groundRooms : upperRooms }

    @State private var selectedRoom: BlueprintRoom? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Floor picker
                Picker("Floor", selection: $selectedFloor) {
                    ForEach(floors.indices, id: \.self) { i in
                        Text(floors[i]).tag(i)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, HAA.Spacing.lg)
                .padding(.vertical, 10)
                .background(Color.white)
                .overlay(Rectangle().fill(HAA.Colors.border).frame(height: 0.5), alignment: .bottom)

                // Legend
                legendRow

                Divider()

                // Blueprint canvas
                GeometryReader { geo in
                    ScrollView([.horizontal, .vertical], showsIndicators: false) {
                        ZStack(alignment: .topLeading) {
                            // Grid background
                            Color(hex: "#F0EDE6")
                            gridLines(in: CGSize(width: 340, height: 430))

                            // Rooms
                            ForEach(currentRooms) { room in
                                blueprintRoom(room: room)
                            }

                            // North arrow
                            VStack(spacing: 2) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(HAA.Colors.charcoal.opacity(0.5))
                                Text("N")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .foregroundColor(HAA.Colors.charcoal.opacity(0.5))
                            }
                            .position(x: 312, y: 18)
                        }
                        .frame(width: 340, height: 430)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(HAA.Colors.border, lineWidth: 1))
                        .padding(HAA.Spacing.lg)
                        .scaleEffect(scale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { val in scale = max(1.0, min(3.0, val)) }
                        )
                    }
                    .background(HAA.Colors.cream)
                }

                // Selected room detail
                if let room = selectedRoom {
                    roomDetailBar(room: room)
                }

                // Reset zoom
                Button {
                    withAnimation { scale = 1.0; selectedRoom = nil }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset View")
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(HAA.Colors.orange)
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle("Venue Map")
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

    // MARK: - Blueprint Room View
    func blueprintRoom(room: BlueprintRoom) -> some View {
        let isSelected = selectedRoom?.id == room.id
        return ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(room.color.opacity(isSelected ? 0.28 : 0.14))
            RoundedRectangle(cornerRadius: 4)
                .stroke(room.color, lineWidth: isSelected ? 2 : 1)

            VStack(alignment: .leading, spacing: 2) {
                Image(systemName: room.icon)
                    .font(.system(size: min(room.h * 0.22, 14), weight: .semibold))
                    .foregroundColor(room.color)
                Text(room.label)
                    .font(.system(size: min(room.h * 0.11, 9), weight: .bold, design: .rounded))
                    .foregroundColor(room.color)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(4)
        }
        .frame(width: room.w, height: room.h)
        .position(x: room.x + room.w / 2, y: room.y + room.h / 2)
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                selectedRoom = (selectedRoom?.id == room.id) ? nil : room
            }
        }
    }

    // MARK: - Grid Lines
    func gridLines(in size: CGSize) -> some View {
        Canvas { ctx, sz in
            let step: CGFloat = 20
            var x: CGFloat = 0
            while x <= sz.width {
                ctx.stroke(Path { p in p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: sz.height)) },
                           with: .color(Color(hex: "#C8A860").opacity(0.12)), lineWidth: 0.5)
                x += step
            }
            var y: CGFloat = 0
            while y <= sz.height {
                ctx.stroke(Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: sz.width, y: y)) },
                           with: .color(Color(hex: "#C8A860").opacity(0.12)), lineWidth: 0.5)
                y += step
            }
        }
    }

    // MARK: - Legend
    var legendRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                legendChip(color: HAA.Colors.orange, label: "Programs")
                legendChip(color: HAA.Colors.gold, label: "Ceremonies")
                legendChip(color: Color(hex: "#1D9E75"), label: "Dining")
                legendChip(color: Color(hex: "#185FA5"), label: "Services")
                legendChip(color: Color(hex: "#166E3F"), label: "Sports/Youth")
                legendChip(color: Color(hex: "#9C27B0"), label: "Activities")
                legendChip(color: Color(hex: "#9E9E9E"), label: "Facilities")
            }
            .padding(.horizontal, HAA.Spacing.lg)
            .padding(.vertical, 8)
        }
        .background(Color.white)
    }

    func legendChip(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(HAA.Colors.muted)
        }
    }

    // MARK: - Room Detail Bar
    func roomDetailBar(room: BlueprintRoom) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(room.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: room.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(room.color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(room.label)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(HAA.Colors.charcoal)
                Text(room.desc)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(HAA.Colors.muted)
                    .lineLimit(1)
            }
            Spacer()
            Button { withAnimation { selectedRoom = nil } } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(HAA.Colors.muted.opacity(0.5))
            }
        }
        .padding(.horizontal, HAA.Spacing.lg)
        .padding(.vertical, 10)
        .background(Color.white)
        .overlay(Rectangle().fill(HAA.Colors.border).frame(height: 0.5), alignment: .top)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Blueprint Room Model
struct BlueprintRoom: Identifiable {
    let id = UUID()
    let label: String
    let color: Color
    let icon: String
    let desc: String
    let x: CGFloat
    let y: CGFloat
    let w: CGFloat
    let h: CGFloat
}
