import SwiftUI

// MARK: - Account View (Registration Login)
struct AccountView: View {
    @StateObject private var auth = AuthViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HAANavBar(title: "My Account", subtitle: "Registration & profile")

            if auth.isLoggedIn {
                ProfileView(auth: auth)
            } else {
                LoginView(auth: auth)
            }
        }
    }
}

// MARK: - Auth ViewModel
class AuthViewModel: ObservableObject {
    @Published var profile = AttendeeProfile()
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    // Persistence via UserDefaults (swap for Firebase/Supabase in production)
    private let profileKey = "haa_attendee_profile"

    init() { loadSaved() }

    func loadSaved() {
        guard let data = UserDefaults.standard.data(forKey: profileKey),
              let saved = try? JSONDecoder().decode(AttendeeProfile.self, from: data) else { return }
        profile = saved
        isLoggedIn = saved.isLoggedIn
    }

    func save() {
        profile.isLoggedIn = true
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }

    // Simulated lookup — replace with real API call to your backend / Firebase
    func login(email: String, registrationID: String) {
        guard !email.isEmpty, !registrationID.isEmpty else {
            errorMessage = "Please enter both your email and registration ID."
            return
        }
        isLoading = true
        errorMessage = nil

        // Simulate network delay then fake lookup
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            // TODO: Replace with real backend check, e.g.:
            //   POST https://api.haaconvention.org/v1/attendee/lookup
            //   Body: { "email": email, "registration_id": registrationID }
            //   Response: { "found": true, "firstName": "...", ... }
            let found = registrationID.uppercased().hasPrefix("HAA")  // demo rule

            if found {
                self.profile = AttendeeProfile(
                    firstName: "Soham",
                    lastName: "Kaje",
                    email: email,
                    chapter: "Midwest Chapter",
                    registrationID: registrationID.uppercased(),
                    membershipType: "Regular",
                    dietaryNote: "No restrictions",
                    isLoggedIn: true
                )
                self.save()
                self.isLoggedIn = true
            } else {
                self.errorMessage = "No registration found for this email and ID. Please check and try again, or contact secretary@havyak.org."
            }
            self.isLoading = false
        }
    }

    func logout() {
        profile = AttendeeProfile()
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: profileKey)
    }
}

// MARK: - Login View
struct LoginView: View {
    @ObservedObject var auth: AuthViewModel
    @State private var email = ""
    @State private var registrationID = ""
    @FocusState private var focusedField: LoginField?

    enum LoginField { case email, regID }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Hero
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(HAA.Colors.orange.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(HAA.Colors.orange)
                    }
                    Text("Load Your Registration")
                        .font(HAA.Font.serif(20, weight: .bold))
                        .foregroundColor(HAA.Colors.charcoal)
                    Text("Enter your registration email and the ID from your confirmation email to access your convention details.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(HAA.Colors.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(
                    HAA.Colors.charcoal
                        .overlay(
                            LinearGradient(
                                colors: [HAA.Colors.charcoal, HAA.Colors.deepBrown],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                )

                VStack(spacing: 20) {
                    // Email field
                    VStack(alignment: .leading, spacing: 6) {
                        formLabel("Email Address")
                        HStack(spacing: 10) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 15))
                                .foregroundColor(HAA.Colors.muted)
                            TextField("your@email.com", text: $email)
                                .font(.system(size: 15, design: .rounded))
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                        }
                        .padding(14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: HAA.Radius.md)
                                .stroke(focusedField == .email ? HAA.Colors.orange : HAA.Colors.border,
                                        lineWidth: focusedField == .email ? 1.5 : 0.5)
                        )
                    }

                    // Registration ID field
                    VStack(alignment: .leading, spacing: 6) {
                        formLabel("Registration ID")
                        HStack(spacing: 10) {
                            Image(systemName: "ticket.fill")
                                .font(.system(size: 15))
                                .foregroundColor(HAA.Colors.muted)
                            TextField("e.g. HAA2026-00123", text: $registrationID)
                                .font(.system(size: 15, design: .rounded))
                                .autocapitalization(.allCharacters)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .regID)
                        }
                        .padding(14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: HAA.Radius.md)
                                .stroke(focusedField == .regID ? HAA.Colors.orange : HAA.Colors.border,
                                        lineWidth: focusedField == .regID ? 1.5 : 0.5)
                        )
                        Text("Found in your registration confirmation email from haaconvention.org")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(HAA.Colors.muted)
                    }

                    // Error message
                    if let err = auth.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                            Text(err)
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.red)
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                    }

                    // Login button
                    Button {
                        focusedField = nil
                        auth.login(email: email, registrationID: registrationID)
                    } label: {
                        HStack(spacing: 8) {
                            if auth.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.85)
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 18))
                            }
                            Text(auth.isLoading ? "Looking up your registration…" : "Load My Registration")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(auth.isLoading ? HAA.Colors.muted : HAA.Colors.orange)
                        .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                    }
                    .buttonStyle(.plain)
                    .disabled(auth.isLoading)

                    // Demo note
                    VStack(spacing: 6) {
                        Divider()
                        Text("DEMO MODE")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .tracking(1)
                            .foregroundColor(HAA.Colors.muted)
                        Text("Use any email + any ID starting with \"HAA\" (e.g. HAA2026-001) to simulate a successful login.")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(HAA.Colors.muted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 4)

                    // Register link
                    VStack(spacing: 6) {
                        Text("Not registered yet?")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(HAA.Colors.muted)
                        Link("Register at haaconvention.org →",
                             destination: URL(string: "https://haaconvention.org/registration/")!)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(HAA.Colors.orange)
                    }
                }
                .padding(.horizontal, HAA.Spacing.lg)
                .padding(.top, 28)
                .padding(.bottom, 90)
            }
        }
        .background(HAA.Colors.cream.ignoresSafeArea())
    }

    func formLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .tracking(0.8)
            .foregroundColor(HAA.Colors.muted)
    }
}

// MARK: - Profile View (logged in)
struct ProfileView: View {
    @ObservedObject var auth: AuthViewModel
    @State private var showLogoutConfirm = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Profile header
                profileHeader

                // Registration card
                VStack(spacing: 10) {
                    registrationCard
                    chapterCard
                    qrPlaceholderCard
                    helpCard
                }
                .padding(.horizontal, HAA.Spacing.lg)
                .padding(.top, 20)

                // Logout
                Button { showLogoutConfirm = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 14))
                        Text("Sign Out")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.red.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, HAA.Spacing.lg)
                .padding(.top, 24)
                .padding(.bottom, 90)
                .confirmationDialog("Sign out of your account?",
                                    isPresented: $showLogoutConfirm,
                                    titleVisibility: .visible) {
                    Button("Sign Out", role: .destructive) { auth.logout() }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
        .background(HAA.Colors.cream.ignoresSafeArea())
    }

    // MARK: - Profile Header
    var profileHeader: some View {
        ZStack(alignment: .bottom) {
            HAA.Colors.charcoal
                .frame(height: 180)

            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(HAA.Colors.orange)
                        .frame(width: 70, height: 70)
                    Text(initials)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                VStack(spacing: 3) {
                    Text("\(auth.profile.firstName) \(auth.profile.lastName)")
                        .font(HAA.Font.serif(20, weight: .bold))
                        .foregroundColor(Color(hex: "#F5E8C0"))
                    Text(auth.profile.email)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(HAA.Colors.mutedLight)
                }
            }
            .padding(.bottom, 20)
        }
    }

    var initials: String {
        let f = auth.profile.firstName.first.map(String.init) ?? ""
        let l = auth.profile.lastName.first.map(String.init) ?? ""
        return f + l
    }

    // MARK: - Cards
    var registrationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardHeader(icon: "ticket.fill", title: "Registration Details", color: HAA.Colors.orange)
            Divider()
            profileRow(icon: "number", label: "Registration ID", value: auth.profile.registrationID)
            profileRow(icon: "person.fill", label: "Membership Type", value: auth.profile.membershipType)
            profileRow(icon: "leaf.fill", label: "Dietary Note", value: auth.profile.dietaryNote.isEmpty ? "None noted" : auth.profile.dietaryNote)
        }
        .haaCard()
    }

    var chapterCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardHeader(icon: "building.2.fill", title: "Chapter", color: HAA.Colors.gold)
            Divider()
            profileRow(icon: "mappin.circle.fill", label: "Chapter", value: auth.profile.chapter)
        }
        .haaCard()
    }

    var qrPlaceholderCard: some View {
        VStack(spacing: 12) {
            cardHeader(icon: "qrcode", title: "Convention Pass", color: HAA.Colors.charcoal)
            Divider()
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "#F0EDE6"))
                    .frame(height: 130)
                VStack(spacing: 8) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 48))
                        .foregroundColor(HAA.Colors.charcoal.opacity(0.25))
                    Text("QR code will be generated when connected to the HAA backend")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(HAA.Colors.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
        }
        .haaCard()
    }

    var helpCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardHeader(icon: "questionmark.circle.fill", title: "Need Help?", color: Color(hex: "#185FA5"))
            Divider()
            Link(destination: URL(string: "mailto:secretary@havyak.org")!) {
                HStack(spacing: 8) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 14))
                    Text("Contact secretary@havyak.org")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundColor(Color(hex: "#185FA5"))
            }
            Link(destination: URL(string: "https://haaconvention.org")!) {
                HStack(spacing: 8) {
                    Image(systemName: "globe")
                        .font(.system(size: 14))
                    Text("Visit haaconvention.org")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundColor(Color(hex: "#185FA5"))
            }
        }
        .haaCard()
    }

    func cardHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(HAA.Colors.charcoal)
        }
    }

    func profileRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(HAA.Colors.gold)
                .frame(width: 18)
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 2) {
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(0.6)
                    .foregroundColor(HAA.Colors.muted)
                Text(value)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(HAA.Colors.charcoal)
            }
        }
    }
}
