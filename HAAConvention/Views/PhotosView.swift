import SwiftUI
import PhotosUI

// MARK: - Photos View
struct PhotosView: View {
    @State private var selectedDayFilter: String = "All"
    @State private var selectedEventFilter: PhotoEventTag? = nil
    @State private var showUploadSheet = false
    @State private var photos = ConventionData.photos
    @State private var selectedPhoto: ConventionPhoto? = nil

    let dayFilters = ["All", "July 2", "July 3", "July 4", "July 5"]

    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
    ]

    var filteredPhotos: [ConventionPhoto] {
        photos.filter { photo in
            let dayMatch  = selectedDayFilter == "All" || photo.day == selectedDayFilter
            let eventMatch = selectedEventFilter == nil || photo.eventTag == selectedEventFilter
            return dayMatch && eventMatch
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HAANavBar(title: "Photos", subtitle: "Convention memories")
            uploadBanner
            dayFilterRow
            eventFilterRow
            photoCountBar

            ScrollView(showsIndicators: false) {
                if filteredPhotos.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(filteredPhotos) { photo in
                            PhotoTile(photo: photo)
                                .onTapGesture { selectedPhoto = photo }
                        }
                    }
                }
                Spacer().frame(height: 90)
            }
            .background(HAA.Colors.cream)
        }
        .sheet(isPresented: $showUploadSheet) {
            UploadPhotoSheet(isPresented: $showUploadSheet) { newPhoto in
                withAnimation { photos.insert(newPhoto, at: 0) }
            }
        }
        .sheet(item: $selectedPhoto) { photo in
            PhotoDetailSheet(photo: photo)
        }
    }

    // MARK: - Upload Banner
    var uploadBanner: some View {
        Button { showUploadSheet = true } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(HAA.Colors.orange.opacity(0.15))
                        .frame(width: 38, height: 38)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(HAA.Colors.orange)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Share your convention moments")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(HAA.Colors.charcoal)
                    Text("Visible to all ~500 attendees")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(HAA.Colors.muted)
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(HAA.Colors.orange)
            }
            .padding(.horizontal, HAA.Spacing.lg)
            .padding(.vertical, 12)
            .background(HAA.Colors.orangeLight)
            .overlay(
                Rectangle().fill(HAA.Colors.orange.opacity(0.15)).frame(height: 0.5),
                alignment: .bottom
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Day Filter Row
    var dayFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(dayFilters, id: \.self) { day in
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectedDayFilter = day }
                    } label: {
                        Text(day)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(selectedDayFilter == day ? HAA.Colors.gold : HAA.Colors.muted)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(selectedDayFilter == day ? HAA.Colors.charcoal : Color.white)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(selectedDayFilter == day ? Color.clear : HAA.Colors.border, lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HAA.Spacing.lg)
            .padding(.vertical, 8)
        }
        .background(Color.white)
    }

    // MARK: - Event Filter Row
    var eventFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All Events" clear chip
                Button {
                    withAnimation(.spring(response: 0.3)) { selectedEventFilter = nil }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "photo.stack.fill")
                            .font(.system(size: 10))
                        Text("All Events")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(selectedEventFilter == nil ? HAA.Colors.orange : HAA.Colors.muted)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(selectedEventFilter == nil ? HAA.Colors.orangeLight : Color.white)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(selectedEventFilter == nil ? HAA.Colors.orange.opacity(0.4) : HAA.Colors.border, lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)

                ForEach(PhotoEventTag.allCases) { tag in
                    let isSelected = selectedEventFilter == tag
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedEventFilter = isSelected ? nil : tag
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: tag.icon)
                                .font(.system(size: 10))
                            Text(tag.rawValue)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(isSelected ? HAA.Colors.orange : HAA.Colors.muted)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isSelected ? HAA.Colors.orangeLight : Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(isSelected ? HAA.Colors.orange.opacity(0.4) : HAA.Colors.border, lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HAA.Spacing.lg)
            .padding(.vertical, 8)
        }
        .background(Color.white)
        .overlay(
            Rectangle().fill(HAA.Colors.border).frame(height: 0.5),
            alignment: .bottom
        )
    }

    // MARK: - Count Bar
    var photoCountBar: some View {
        HStack {
            Text("\(filteredPhotos.count) photo\(filteredPhotos.count == 1 ? "" : "s")")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(HAA.Colors.muted)
            if selectedEventFilter != nil || selectedDayFilter != "All" {
                Text("· filtered")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(HAA.Colors.orange)
            }
            Spacer()
            Button { showUploadSheet = true } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                    Text("Add yours")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(HAA.Colors.orange)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, HAA.Spacing.lg)
        .padding(.vertical, 8)
        .background(HAA.Colors.cream)
    }

    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 40))
                .foregroundColor(HAA.Colors.muted.opacity(0.4))
            Text("No photos match this filter")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(HAA.Colors.muted)
            Button { showUploadSheet = true } label: {
                Text("Be the first to upload")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(HAA.Colors.orange)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

// MARK: - Photo Tile
struct PhotoTile: View {
    let photo: ConventionPhoto

    var body: some View {
        GeometryReader { _ in
            ZStack {
                photo.accentColor.opacity(0.15)
                Image(systemName: photo.imageName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(photo.accentColor.opacity(0.7))
                VStack {
                    Spacer()
                    Text(photo.caption)
                        .font(.system(size: 8, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 3)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color.clear, Color.black.opacity(0.55)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

// MARK: - Upload Photo Sheet
struct UploadPhotoSheet: View {
    @Binding var isPresented: Bool
    let onUpload: (ConventionPhoto) -> Void

    @State private var caption        = ""
    @State private var selectedDay    = "July 3"
    @State private var selectedTag    = PhotoEventTag.general
    @State private var uploaderName   = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var showSuccess    = false
    @State private var isUploading    = false

    let days = ["July 2", "July 3", "July 4", "July 5"]

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    photoPickerSection
                    Divider().padding(.vertical, 20)
                    formSection
                    Spacer().frame(height: 20)

                    if showSuccess {
                        successBanner
                            .padding(.horizontal, HAA.Spacing.lg)
                    } else {
                        HAAButton(
                            label: isUploading ? "Uploading…" : "Share with Everyone",
                            icon: isUploading ? nil : "arrow.up.circle.fill",
                            action: handleUpload
                        )
                        .disabled(isUploading)
                        .padding(.horizontal, HAA.Spacing.lg)
                    }

                    Text("Your photo will be visible to all convention attendees and reusable in future HAA apps.")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(HAA.Colors.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, HAA.Spacing.lg)
                        .padding(.top, 12)

                    Spacer().frame(height: 40)
                }
                .padding(.top, 8)
            }
            .background(HAA.Colors.cream.ignoresSafeArea())
            .navigationTitle("Add Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(HAA.Colors.muted)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { isPresented = false }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(HAA.Colors.orange)
                }
            }
        }
    }

    // MARK: Photo Picker
    var photoPickerSection: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            ZStack {
                RoundedRectangle(cornerRadius: HAA.Radius.lg)
                    .fill(Color.white)
                    .frame(height: 170)
                    .overlay(
                        RoundedRectangle(cornerRadius: HAA.Radius.lg)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                            .foregroundColor(HAA.Colors.orange.opacity(0.5))
                    )

                if selectedImageData != nil {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color(hex: "#1D9E75"))
                        Text("Photo selected")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "#1D9E75"))
                        Text("Tap to change")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(HAA.Colors.muted)
                    }
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 36, weight: .light))
                            .foregroundColor(HAA.Colors.orange)
                        Text("Tap to choose a photo")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(HAA.Colors.charcoal)
                        Text("From your camera roll")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(HAA.Colors.muted)
                    }
                }
            }
            .padding(.horizontal, HAA.Spacing.lg)
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }

    // MARK: Form
    var formSection: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Caption
            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("Caption")
                TextField("What's happening in this photo?", text: $caption, axis: .vertical)
                    .font(.system(size: 14, design: .rounded))
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                    .overlay(RoundedRectangle(cornerRadius: HAA.Radius.md).stroke(HAA.Colors.border, lineWidth: 0.5))
                    .lineLimit(3)
            }

            // Name
            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("Your name / Chapter")
                TextField("e.g. Midwest Chapter, or Priya Bhat", text: $uploaderName)
                    .font(.system(size: 14, design: .rounded))
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                    .overlay(RoundedRectangle(cornerRadius: HAA.Radius.md).stroke(HAA.Colors.border, lineWidth: 0.5))
            }

            // Day picker
            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Convention Day")
                HStack(spacing: 8) {
                    ForEach(days, id: \.self) { day in
                        Button {
                            withAnimation(.spring(response: 0.3)) { selectedDay = day }
                        } label: {
                            Text(day)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(selectedDay == day ? .white : HAA.Colors.muted)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(selectedDay == day ? HAA.Colors.orange : Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.sm))
                                .overlay(
                                    RoundedRectangle(cornerRadius: HAA.Radius.sm)
                                        .stroke(selectedDay == day ? Color.clear : HAA.Colors.border, lineWidth: 0.5)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Event Tag picker
            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Event Tag")
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 8
                ) {
                    ForEach(PhotoEventTag.allCases) { tag in
                        let isSelected = selectedTag == tag
                        Button {
                            withAnimation(.spring(response: 0.3)) { selectedTag = tag }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: tag.icon)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(isSelected ? HAA.Colors.orange : HAA.Colors.muted)
                                Text(tag.rawValue)
                                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                                    .foregroundColor(isSelected ? HAA.Colors.orange : HAA.Colors.muted)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(isSelected ? HAA.Colors.orangeLight : Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: HAA.Radius.md)
                                    .stroke(isSelected ? HAA.Colors.orange.opacity(0.5) : HAA.Colors.border, lineWidth: isSelected ? 1 : 0.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, HAA.Spacing.lg)
    }

    func fieldLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .tracking(0.8)
            .foregroundColor(HAA.Colors.muted)
    }

    var successBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(Color(hex: "#1D9E75"))
            VStack(alignment: .leading, spacing: 2) {
                Text("Photo shared!")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1D9E75"))
                Text("Now visible to all attendees")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(HAA.Colors.muted)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(hex: "#E1F5EE"))
        .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
    }

    func handleUpload() {
        isUploading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let icons = ["photo.fill", "heart.fill", "star.fill", "sparkles"]
            let newPhoto = ConventionPhoto(
                imageName:   icons.randomElement() ?? "photo.fill",
                caption:     caption.isEmpty ? "Convention moment" : caption,
                uploadedBy:  uploaderName.isEmpty ? "Anonymous" : uploaderName,
                day:         selectedDay,
                eventTag:    selectedTag,
                accentColor: HAA.Colors.orange
            )
            onUpload(newPhoto)
            isUploading = false
            showSuccess  = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isPresented = false
            }
        }
    }
}

// MARK: - Photo Detail Sheet
struct PhotoDetailSheet: View {
    let photo: ConventionPhoto
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    photo.accentColor.opacity(0.12)
                    Image(systemName: photo.imageName)
                        .font(.system(size: 80, weight: .light))
                        .foregroundColor(photo.accentColor.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)

                VStack(alignment: .leading, spacing: 14) {
                    Text(photo.caption)
                        .font(HAA.Font.serif(20, weight: .bold))
                        .foregroundColor(HAA.Colors.charcoal)

                    HStack(spacing: 8) {
                        // Event tag chip
                        HStack(spacing: 4) {
                            Image(systemName: photo.eventTag.icon)
                                .font(.system(size: 10))
                            Text(photo.eventTag.rawValue)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(HAA.Colors.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(HAA.Colors.orangeLight)
                        .clipShape(Capsule())

                        Label(photo.day, systemImage: "calendar")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(HAA.Colors.muted)
                    }

                    Label(photo.uploadedBy, systemImage: "person.fill")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(HAA.Colors.muted)

                    Divider()

                    HStack(spacing: 12) {
                        Button {} label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(HAA.Colors.orange)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(HAA.Colors.orangeLight)
                                .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                        }
                        .buttonStyle(.plain)

                        Button {} label: {
                            Label("Save", systemImage: "arrow.down.circle.fill")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(HAA.Colors.orange)
                                .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(HAA.Spacing.lg)
                .background(HAA.Colors.cream)
                Spacer()
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
        }
    }
}
