import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Photos View
struct PhotosView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var network: NetworkMonitor
    @Binding var selectedTab: Int
    @Binding var moreSectionRequest: InfoAccountSection?

    @State private var selectedDayFilter: String = "All"
    @State private var selectedEventFilter: PhotoEventTag? = nil
    @State private var showUploadSheet = false
    @State private var photos: [ConventionPhoto] = []
    @State private var selectedPhoto: ConventionPhoto? = nil
    @State private var isLoadingGallery = false
    @State private var galleryError: String?

    let dayFilters = ["All", "July 2", "July 3", "July 4", "July 5"]

    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
    ]

    var filteredPhotos: [ConventionPhoto] {
        photos.filter { photo in
            let dayMatch = selectedDayFilter == "All" || photo.day == selectedDayFilter
            let eventMatch = selectedEventFilter == nil || photo.eventTag == selectedEventFilter
            return dayMatch && eventMatch
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HAANavBar(title: "Photos", subtitle: "Convention memories")

            if !network.isConnected {
                OfflineBanner(
                    message: "No internet connection. The photo gallery requires service to view and upload."
                )
            }

            if auth.isLoggedIn {
                galleryContent
            } else {
                PhotosLoginGate(selectedTab: $selectedTab, moreSectionRequest: $moreSectionRequest)
            }
        }
        .task(id: auth.isLoggedIn) {
            guard auth.isLoggedIn, network.isConnected else { return }
            await loadGallery()
        }
    }

    private var galleryContent: some View {
        VStack(spacing: 0) {
            uploadBanner
            dayFilterRow
            eventFilterRow
            photoCountBar

            ScrollView(showsIndicators: false) {
                if isLoadingGallery && photos.isEmpty {
                    ProgressView("Loading gallery…")
                        .padding(.top, 60)
                } else if filteredPhotos.isEmpty {
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
            UploadPhotoSheet(
                isPresented: $showUploadSheet,
                uploaderName: auth.displayName,
                uploaderEmail: auth.profile.email
            ) { newPhoto in
                withAnimation { photos.insert(newPhoto, at: 0) }
            }
        }
        .sheet(item: $selectedPhoto) { photo in
            PhotoDetailSheet(
                photo: photo,
                currentUserEmail: auth.profile.email
            ) { deletedId in
                withAnimation {
                    photos.removeAll { $0.id == deletedId }
                }
            }
        }
    }

    func loadGallery() async {
        isLoadingGallery = true
        galleryError = nil
        do {
            photos = try await PhotosAPI.fetchGallery()
        } catch {
            galleryError = error.localizedDescription
        }
        isLoadingGallery = false
    }

    var uploadBanner: some View {
        Button {
            guard network.isConnected else { return }
            showUploadSheet = true
        } label: {
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
                    Text("Photos & videos up to \(PhotosLimits.maxUploadMB) MB")
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
        .disabled(!network.isConnected)
        .opacity(network.isConnected ? 1 : 0.5)
    }

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

    var eventFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    withAnimation(.spring(response: 0.3)) { selectedEventFilter = nil }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "photo.stack.fill").font(.system(size: 10))
                        Text("All Events").font(.system(size: 11, weight: .semibold, design: .rounded))
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
                            Image(systemName: tag.icon).font(.system(size: 10))
                            Text(tag.rawValue).font(.system(size: 11, weight: .semibold, design: .rounded))
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
        .overlay(Rectangle().fill(HAA.Colors.border).frame(height: 0.5), alignment: .bottom)
    }

    var photoCountBar: some View {
        HStack {
            Text("\(filteredPhotos.count) item\(filteredPhotos.count == 1 ? "" : "s")")
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
                    Image(systemName: "plus").font(.system(size: 11, weight: .bold))
                    Text("Add yours").font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(HAA.Colors.orange)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, HAA.Spacing.lg)
        .padding(.vertical, 8)
        .background(HAA.Colors.cream)
    }

    var emptyStateMessage: String {
        if let galleryError { return galleryError }
        if photos.isEmpty { return "No photos yet. Be the first to share a convention memory!" }
        return "No photos match this filter"
    }

    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 40))
                .foregroundColor(HAA.Colors.muted.opacity(0.4))
            Text(emptyStateMessage)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(HAA.Colors.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
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

// MARK: - Login Gate
struct PhotosLoginGate: View {
    @Binding var selectedTab: Int
    @Binding var moreSectionRequest: InfoAccountSection?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 44))
                .foregroundColor(HAA.Colors.orange.opacity(0.7))
            Text("Sign in to view photos")
                .font(HAA.Font.serif(22, weight: .bold))
                .foregroundColor(HAA.Colors.charcoal)
            Text("The shared convention gallery is available to logged-in attendees only.")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(HAA.Colors.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button {
                moreSectionRequest = .account
                withAnimation { selectedTab = 4 }
            } label: {
                Text("Go to Account")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(HAA.Colors.orange)
                    .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HAA.Colors.cream)
    }
}

// MARK: - Photo Tile
struct PhotoTile: View {
    let photo: ConventionPhoto

    var body: some View {
        GeometryReader { _ in
            ZStack {
                if let urlString = photo.mediaURL, let url = URL(string: urlString) {
                    if photo.isVideo {
                        Color.black.opacity(0.85)
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white.opacity(0.9))
                    } else {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                photo.accentColor.opacity(0.15)
                            }
                        }
                    }
                } else {
                    photo.accentColor.opacity(0.15)
                    Image(systemName: photo.imageName)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(photo.accentColor.opacity(0.7))
                }

                if photo.isVideo {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "video.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.black.opacity(0.55))
                                .clipShape(Circle())
                                .padding(6)
                        }
                        Spacer()
                    }
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
    let uploaderName: String
    let uploaderEmail: String
    let onUpload: (ConventionPhoto) -> Void

    @State private var caption = ""
    @State private var selectedDay = "July 3"
    @State private var selectedTag = PhotoEventTag.general
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedFileData: Data? = nil
    @State private var selectedMediaType: PhotoMediaType = .image
    @State private var selectedFileName = "upload.jpg"
    @State private var showSuccess = false
    @State private var isUploading = false
    @State private var uploadError: String?

    let days = ["July 2", "July 3", "July 4", "July 5"]

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    mediaPickerSection
                    Divider().padding(.vertical, 20)
                    formSection
                    Spacer().frame(height: 20)

                    if let uploadError {
                        Text(uploadError)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.red)
                            .padding(.horizontal, HAA.Spacing.lg)
                            .padding(.bottom, 8)
                    }

                    if showSuccess {
                        successBanner.padding(.horizontal, HAA.Spacing.lg)
                    } else {
                        HAAButton(
                            label: isUploading ? "Uploading…" : "Share with Everyone",
                            icon: isUploading ? nil : "arrow.up.circle.fill",
                            action: handleUpload
                        )
                        .disabled(isUploading || selectedFileData == nil)
                        .padding(.horizontal, HAA.Spacing.lg)
                    }

                    Text("Max file size: \(PhotosLimits.maxUploadMB) MB. Shared with all logged-in attendees.")
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
            .navigationTitle("Add Photo or Video")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(HAA.Colors.muted)
                }
            }
        }
    }

    var mediaPickerSection: some View {
        PhotosPicker(selection: $selectedItem, matching: .any(of: [.images, .videos])) {
            ZStack {
                RoundedRectangle(cornerRadius: HAA.Radius.lg)
                    .fill(Color.white)
                    .frame(height: 170)
                    .overlay(
                        RoundedRectangle(cornerRadius: HAA.Radius.lg)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                            .foregroundColor(HAA.Colors.orange.opacity(0.5))
                    )

                if selectedFileData != nil {
                    VStack(spacing: 8) {
                        Image(systemName: selectedMediaType == .video ? "video.fill" : "checkmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color(hex: "#1D9E75"))
                        Text(selectedMediaType == .video ? "Video selected" : "Photo selected")
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
                        Text("Tap to choose a photo or video")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(HAA.Colors.charcoal)
                        Text("Up to \(PhotosLimits.maxUploadMB) MB")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(HAA.Colors.muted)
                    }
                }
            }
            .padding(.horizontal, HAA.Spacing.lg)
        }
        .onChange(of: selectedItem) { _, newItem in
            Task { await loadSelectedItem(newItem) }
        }
    }

    func loadSelectedItem(_ item: PhotosPickerItem?) async {
        uploadError = nil
        guard let item else {
            selectedFileData = nil
            return
        }

        let isVideo = item.supportedContentTypes.contains { $0.conforms(to: .movie) || $0.conforms(to: .video) }
        selectedMediaType = isVideo ? .video : .image
        selectedFileName = isVideo ? "upload.mp4" : "upload.jpg"

        if let data = try? await item.loadTransferable(type: Data.self) {
            if let sizeError = PhotosLimits.validateFileSize(Int64(data.count)) {
                uploadError = sizeError
                selectedFileData = nil
                return
            }
            selectedFileData = data
        }
    }

    var formSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("Caption")
                TextField("What's happening?", text: $caption, axis: .vertical)
                    .font(.system(size: 14, design: .rounded))
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                    .overlay(RoundedRectangle(cornerRadius: HAA.Radius.md).stroke(HAA.Colors.border, lineWidth: 0.5))
                    .lineLimit(3)
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("Shared as")
                Text(uploaderName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(HAA.Colors.charcoal)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                    .overlay(RoundedRectangle(cornerRadius: HAA.Radius.md).stroke(HAA.Colors.border, lineWidth: 0.5))
            }

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
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Event Tag")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
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
                Text("Shared!")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1D9E75"))
                Text("Now visible in the gallery")
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
        guard let data = selectedFileData else { return }
        isUploading = true
        uploadError = nil

        Task {
            do {
                let mime = selectedMediaType == .video ? "video/mp4" : "image/jpeg"
                let photo = try await PhotosAPI.upload(
                    fileData: data,
                    fileName: selectedFileName,
                    mimeType: mime,
                    mediaType: selectedMediaType,
                    caption: caption.isEmpty ? "Convention moment" : caption,
                    day: selectedDay,
                    eventTag: selectedTag,
                    uploadedBy: uploaderName,
                    uploaderEmail: uploaderEmail
                )
                onUpload(photo)
                isUploading = false
                showSuccess = true
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                isPresented = false
            } catch {
                uploadError = error.localizedDescription
                isUploading = false
            }
        }
    }
}

// MARK: - Photo Detail Sheet
struct PhotoDetailSheet: View {
    let photo: ConventionPhoto
    let currentUserEmail: String
    let onDelete: (String) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var showDeleteConfirm = false
    @State private var isDeleting = false
    @State private var deleteError: String?

    private var canDelete: Bool {
        let owner = photo.uploaderEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let current = currentUserEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return !owner.isEmpty && owner == current
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    if let urlString = photo.mediaURL, let url = URL(string: urlString), !photo.isVideo {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFit()
                            default:
                                placeholderMedia
                            }
                        }
                    } else {
                        placeholderMedia
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .background(Color.black.opacity(0.05))

                VStack(alignment: .leading, spacing: 14) {
                    attributionBox

                    Text(photo.caption)
                        .font(HAA.Font.serif(20, weight: .bold))
                        .foregroundColor(HAA.Colors.charcoal)

                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: photo.eventTag.icon).font(.system(size: 10))
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

                    if let deleteError {
                        Text(deleteError)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.red)
                    }

                    if canDelete {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            HStack(spacing: 8) {
                                if isDeleting {
                                    ProgressView().tint(.red).scaleEffect(0.85)
                                } else {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 14))
                                }
                                Text(isDeleting ? "Deleting…" : "Delete \(photo.isVideo ? "Video" : "Photo")")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                        }
                        .buttonStyle(.plain)
                        .disabled(isDeleting)
                    }
                }
                .padding(HAA.Spacing.lg)
                .background(HAA.Colors.cream)
                Spacer()
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(HAA.Colors.orange)
                }
            }
            .confirmationDialog(
                "Delete this \(photo.isVideo ? "video" : "photo")?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) { deletePhoto() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone. It will be removed from the shared gallery.")
            }
        }
    }

    private func deletePhoto() {
        isDeleting = true
        deleteError = nil

        Task {
            do {
                try await PhotosAPI.delete(
                    photoId: photo.id,
                    uploaderEmail: currentUserEmail
                )
                onDelete(photo.id)
                dismiss()
            } catch {
                deleteError = error.localizedDescription
                isDeleting = false
            }
        }
    }

    private var placeholderMedia: some View {
        ZStack {
            photo.accentColor.opacity(0.12)
            Image(systemName: photo.imageName)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(photo.accentColor.opacity(0.6))
        }
    }

    private var attributionBox: some View {
        HStack(spacing: 10) {
            Image(systemName: photo.isVideo ? "video.fill" : "photo.fill")
                .font(.system(size: 14))
                .foregroundColor(HAA.Colors.orange)
            Text("\(photo.uploadedBy) added this \(photo.isVideo ? "video" : "image")")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(HAA.Colors.charcoal)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HAA.Colors.orangeLight.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
    }
}
