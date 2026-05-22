import SwiftUI
import MapKit

// MARK: - Map View
struct MapView: View {
    @State private var selectedCategory: LocationCategory = .all
    @State private var selectedLocation: ConventionLocation? = nil
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
            .overlay(
                Rectangle().fill(HAA.Colors.border).frame(height: 0.5),
                alignment: .bottom
            )

            // Map
            mapSection

            // Location list
            locationList
        }
        .sheet(item: $selectedLocation) { loc in
            LocationDetailSheet(location: loc)
        }
    }

    // MARK: - Map Section
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
                            cameraPosition = .region(
                                MKCoordinateRegion(
                                    center: loc.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                                )
                            )
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
        .frame(height: 240)
    }

    // MARK: - Location List
    var locationList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(filteredLocations) { loc in
                    LocationRow(location: loc, isSelected: selectedLocation?.id == loc.id) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedLocation = loc
                            cameraPosition = .region(
                                MKCoordinateRegion(
                                    center: loc.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                                )
                            )
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
        if filteredLocations.isEmpty { return }
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

// MARK: - Map Pin View
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
                        Circle()
                            .stroke(Color.white, lineWidth: 2.5)
                            .frame(width: 40, height: 40)
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
                    // Embedded map
                    Map(position: $mapPosition) {
                        Annotation(location.name, coordinate: location.coordinate) {
                            MapPinView(location: location, isSelected: true, onTap: {})
                        }
                    }
                    .mapStyle(.standard(elevation: .realistic))
                    .frame(height: 200)

                    // Details
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 6) {
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
                        }

                        Divider()

                        // Address
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

                        // Details
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

                        // Open in Maps button
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
