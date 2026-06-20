import SwiftUI
import CoreImage

// MARK: - Access View
struct AccessView: View {
    @ObservedObject var auth: AuthViewModel
    @EnvironmentObject var network: NetworkMonitor
    @State private var screen: AuthScreen = .welcome
    @State private var email = ""
    @State private var loginCode = ""
    @State private var signUpCodeSent = false
    @FocusState private var focusedField: Field?

    enum AuthScreen {
        case welcome, signUp, logIn
    }

    enum Field {
        case email, code
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                hero

                VStack(spacing: 20) {
                    switch screen {
                    case .welcome:
                        welcomeContent
                    case .signUp:
                        signUpContent
                    case .logIn:
                        logInContent
                    }
                }
                .padding(.horizontal, HAA.Spacing.lg)
                .padding(.top, 28)
                .padding(.bottom, 90)
            }
        }
        .background(HAA.Colors.cream.ignoresSafeArea())
    }

    // MARK: - Welcome

    private var hero: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(HAA.Colors.orange.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(HAA.Colors.orange)
            }
            Text(heroTitle)
                .font(HAA.Font.serif(20, weight: .bold))
                .foregroundColor(Color(hex: "#F5E8C0"))
            Text(heroSubtitle)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(HAA.Colors.mutedLight)
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
    }

    private var heroTitle: String {
        switch screen {
        case .welcome: return "My Account"
        case .signUp:  return "Sign Up"
        case .logIn:   return "Log In"
        }
    }

    private var heroSubtitle: String {
        switch screen {
        case .welcome:
            return "Sign up to receive your login code, or log in if you already have it."
        case .signUp:
            return "Enter the email of whoever registered your group. We'll email the 5-digit login code to that inbox."
        case .logIn:
            return "Enter the registrant email and the 5-digit code that was emailed to you."
        }
    }

    private var welcomeContent: some View {
        VStack(spacing: 12) {
            primaryNavButton(title: "Sign Up", icon: "person.badge.plus") {
                resetForm()
                screen = .signUp
            }

            primaryNavButton(title: "Log In", icon: "arrow.right.circle") {
                resetForm()
                screen = .logIn
            }
        }
    }

    // MARK: - Sign Up

    private var signUpContent: some View {
        VStack(spacing: 20) {
            backButton

            emailField

            if signUpCodeSent {
                codeField
                infoBanner
                errorBanner

                Button {
                    focusedField = nil
                    auth.login(email: email, code: loginCode)
                } label: {
                    submitLabel(
                        loading: auth.isLoading,
                        loadingText: "Signing in…",
                        text: "Complete Sign Up",
                        icon: "checkmark.circle.fill"
                    )
                }
                .buttonStyle(.plain)
                .disabled(auth.isLoading || auth.isSendingCode || !network.isConnected)
            } else {
                errorBanner

                Button {
                    focusedField = nil
                    auth.sendLoginCode(email: email)
                } label: {
                    submitLabel(
                        loading: auth.isSendingCode,
                        loadingText: "Sending code…",
                        text: "Send Login Code",
                        icon: "envelope.arrow.triangle.branch"
                    )
                }
                .buttonStyle(.plain)
                .disabled(auth.isSendingCode || !network.isConnected)
            }

            signUpHelp
        }
        .onChange(of: auth.infoMessage) { _, newValue in
            if newValue != nil { signUpCodeSent = true }
        }
    }

    // MARK: - Log In

    private var logInContent: some View {
        VStack(spacing: 20) {
            backButton
            emailField
            codeField
            infoBanner
            errorBanner

            Button {
                focusedField = nil
                auth.login(email: email, code: loginCode)
            } label: {
                submitLabel(
                    loading: auth.isLoading,
                    loadingText: "Signing in…",
                    text: "Log In",
                    icon: "arrow.right.circle.fill"
                )
            }
            .buttonStyle(.plain)
            .disabled(auth.isLoading || !network.isConnected)

            logInHelp
        }
    }

    // MARK: - Shared components

    private var backButton: some View {
        Button {
            resetForm()
            screen = .welcome
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
                Text("Back")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundColor(HAA.Colors.muted)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emailField: some View {
        formField(
            label: "Registrant Email",
            icon: "envelope.fill",
            text: $email,
            field: .email,
            placeholder: "registrant@email.com",
            keyboard: .emailAddress
        )
    }

    private var codeField: some View {
        formField(
            label: "5-Digit Login Code",
            icon: "lock.fill",
            text: $loginCode,
            field: .code,
            placeholder: "12345",
            keyboard: .numberPad
        )
        .onChange(of: loginCode) { _, newValue in
            loginCode = String(newValue.filter(\.isNumber).prefix(5))
        }
    }

    @ViewBuilder
    private var infoBanner: some View {
        if let info = auth.infoMessage {
            banner(text: info, icon: "checkmark.circle.fill", color: Color(hex: "#166E3F"), bg: Color(hex: "#E8F8F0"))
        }
    }

    @ViewBuilder
    private var errorBanner: some View {
        if let err = auth.errorMessage {
            banner(text: err, icon: "exclamationmark.triangle.fill", color: .red, bg: Color.red.opacity(0.07))
        }
    }

    private var signUpHelp: some View {
        helpCard("If someone else registered for you, use their email address — the login code will be sent to that inbox.")
    }

    private var logInHelp: some View {
        helpCard("Use the registrant email and the 5-digit code from your email. Don't have a code yet? Go back and choose Sign Up.")
    }

    private func resetForm() {
        email = ""
        loginCode = ""
        signUpCodeSent = false
        auth.errorMessage = nil
        auth.infoMessage = nil
        focusedField = nil
    }

    private func primaryNavButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .opacity(0.5)
            }
            .foregroundColor(HAA.Colors.charcoal)
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: HAA.Radius.md)
                    .stroke(HAA.Colors.border, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func submitLabel(loading: Bool, loadingText: String, text: String, icon: String) -> some View {
        HStack(spacing: 8) {
            if loading {
                ProgressView().tint(.white).scaleEffect(0.85)
            } else {
                Image(systemName: icon).font(.system(size: 18))
            }
            Text(loading ? loadingText : text)
                .font(.system(size: 15, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(loading ? HAA.Colors.muted : HAA.Colors.orange)
        .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
    }

    private func helpCard(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, design: .rounded))
            .foregroundColor(HAA.Colors.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(HAA.Colors.goldLight.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
    }

    private func banner(text: String, icon: String, color: Color, bg: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(color).font(.system(size: 14))
            Text(text).font(.system(size: 13, design: .rounded)).foregroundColor(color)
        }
        .padding(12)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
    }

    private func formField(
        label: String,
        icon: String,
        text: Binding<String>,
        field: Field,
        placeholder: String,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            formLabel(label)
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(HAA.Colors.muted)
                TextField(placeholder, text: text)
                    .font(.system(size: 15, design: .rounded))
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(keyboard == .emailAddress ? .never : .never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: field)
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: HAA.Radius.md)
                    .stroke(focusedField == field ? HAA.Colors.orange : HAA.Colors.border,
                            lineWidth: focusedField == field ? 1.5 : 0.5)
            )
        }
    }

    private func formLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .tracking(0.8)
            .foregroundColor(HAA.Colors.muted)
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @ObservedObject var auth: AuthViewModel
    @EnvironmentObject var network: NetworkMonitor
    @State private var showLogoutConfirm = false
    @State private var showCheckInSheet = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                profileHeader

                VStack(spacing: 10) {
                    accountCard
                    if auth.profile.hasCheckedIn {
                        checkedInCard
                    } else {
                        checkInButton
                    }
                    if let info = auth.infoMessage {
                        banner(text: info, icon: "checkmark.circle.fill", color: Color(hex: "#166E3F"), bg: Color(hex: "#E8F8F0"))
                    }
                    if let err = auth.errorMessage {
                        banner(text: err, icon: "exclamationmark.triangle.fill", color: .red, bg: Color.red.opacity(0.07))
                    }
                    helpCard
                }
                .padding(.horizontal, HAA.Spacing.lg)
                .padding(.top, 20)

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
        .sheet(isPresented: $showCheckInSheet) {
            CheckInQRSheet(auth: auth)
        }
        .onChange(of: auth.profile.hasCheckedIn) { _, checkedIn in
            if checkedIn {
                showCheckInSheet = false
            }
        }
        .task(id: auth.profile.hasCheckedIn) {
            guard !auth.profile.hasCheckedIn else { return }
            await auth.refreshRegistrationStatus()
            guard !auth.profile.hasCheckedIn else { return }

            while !Task.isCancelled && !auth.profile.hasCheckedIn {
                guard network.isConnected else {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    continue
                }

                if await auth.refreshRegistrationStatus() {
                    auth.markCheckedInFromVolunteerScan()
                    break
                }

                try? await Task.sleep(nanoseconds: 3_000_000_000)
            }
        }
    }

    private var profileHeader: some View {
        ZStack(alignment: .bottom) {
            HAA.Colors.charcoal.frame(height: 180)

            VStack(spacing: 10) {
                ZStack {
                    Circle().fill(HAA.Colors.orange).frame(width: 70, height: 70)
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

    private var initials: String {
        let f = auth.profile.firstName.first.map(String.init) ?? ""
        let l = auth.profile.lastName.first.map(String.init) ?? ""
        return f + l
    }

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardHeader(icon: "person.text.rectangle.fill", title: "Account", color: HAA.Colors.orange)
            Divider()
            profileRow(icon: "person.fill", label: "First Name", value: auth.profile.firstName)
            profileRow(icon: "person.fill", label: "Last Name", value: auth.profile.lastName)
            profileRow(icon: "envelope.fill", label: "Linked Email", value: auth.profile.email)
        }
        .haaCard()
    }

    private var checkedInCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 22))
                .foregroundColor(Color(hex: "#1D9E75"))
            VStack(alignment: .leading, spacing: 2) {
                Text("Checked In")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(HAA.Colors.charcoal)
                Text("Your convention check-in is complete.")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(HAA.Colors.muted)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(hex: "#E8F8F0"))
        .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: HAA.Radius.lg)
                .stroke(Color(hex: "#1D9E75").opacity(0.25), lineWidth: 0.5)
        )
    }

    private var checkInButton: some View {
        Button {
            showCheckInSheet = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "qrcode")
                    .font(.system(size: 18))
                Text("Check In")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(HAA.Colors.orange)
            .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
        }
        .buttonStyle(.plain)
    }

    private var helpCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardHeader(icon: "questionmark.circle.fill", title: "Need Help?", color: Color(hex: "#185FA5"))
            Divider()
            Link(destination: URL(string: "mailto:secretary@havyak.org")!) {
                HStack(spacing: 8) {
                    Image(systemName: "envelope.fill").font(.system(size: 14))
                    Text("Contact secretary@havyak.org")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundColor(Color(hex: "#185FA5"))
            }
        }
        .haaCard()
    }

    private func cardHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 15, weight: .semibold)).foregroundColor(color)
            Text(title).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(HAA.Colors.charcoal)
        }
    }

    private func profileRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon).font(.system(size: 13)).foregroundColor(HAA.Colors.gold).frame(width: 18).padding(.top, 1)
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

    private func banner(text: String, icon: String, color: Color, bg: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(color).font(.system(size: 14))
            Text(text).font(.system(size: 13, design: .rounded)).foregroundColor(color)
        }
        .padding(12)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
    }
}

// MARK: - Check-In QR Sheet
struct CheckInQRSheet: View {
    @ObservedObject var auth: AuthViewModel
    @EnvironmentObject var network: NetworkMonitor
    @Environment(\.dismiss) private var dismiss

    private let steps: [(number: String, title: String, detail: String)] = [
        ("1", "Head to the Check-In Desk", "When you arrive at the venue, walk up to the Main Registration & Check-In Desk in the event hall."),
        ("2", "Show your QR code", "Present the QR code below to one of our volunteers — on your phone screen or a printout. A quick scan instantly pulls up your registration."),
        ("3", "Collect your badges & souvenir", "Once scanned, you'll receive your official name badges and your custom convention souvenir packet. That's it — you're in!"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("How Check-In Works — 3 Easy Steps")
                        .font(HAA.Font.serif(20, weight: .bold))
                        .foregroundColor(HAA.Colors.charcoal)

                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(steps, id: \.number) { step in
                            HStack(alignment: .top, spacing: 12) {
                                Text(step.number)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 26, height: 26)
                                    .background(HAA.Colors.orange)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(step.title)
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(HAA.Colors.charcoal)
                                    Text(step.detail)
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundColor(HAA.Colors.muted)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }

                    qrSection
                }
                .padding(HAA.Spacing.lg)
                .padding(.bottom, 24)
            }
            .background(HAA.Colors.cream.ignoresSafeArea())
            .navigationTitle("Convention Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
            }
            .task {
                guard !auth.profile.hasCheckedIn else {
                    dismiss()
                    return
                }

                while !Task.isCancelled && !auth.profile.hasCheckedIn {
                    guard network.isConnected else {
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        continue
                    }

                    if await auth.refreshRegistrationStatus() {
                        auth.markCheckedInFromVolunteerScan()
                        dismiss()
                        break
                    }

                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                }
            }
        }
    }

    @ViewBuilder
    private var qrSection: some View {
        VStack(spacing: 12) {
            if auth.profile.hasCheckedIn {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(hex: "#1D9E75"))
                    Text("You're checked in!")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(HAA.Colors.charcoal)
                    Text("Your registration was confirmed by our volunteers.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(HAA.Colors.muted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color(hex: "#E8F8F0"))
                .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.lg))
            } else if let url = auth.profile.checkInURL {
                QRCodeImageView(text: url.absoluteString)
                    .frame(width: 220, height: 220)
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: HAA.Radius.lg)
                            .stroke(HAA.Colors.border, lineWidth: 0.5)
                    )
                    .frame(maxWidth: .infinity)

                Text("\(auth.profile.firstName) \(auth.profile.lastName)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(HAA.Colors.charcoal)

                Text(auth.profile.email)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(HAA.Colors.muted)

                if network.isConnected {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Waiting for volunteer to scan your code…")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(HAA.Colors.muted)
                    }
                    .padding(.top, 4)
                }
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(HAA.Colors.orange)
                    Text("Your check-in QR code isn't available yet.")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(HAA.Colors.charcoal)
                        .multilineTextAlignment(.center)
                    Text("Sign out and log in again to refresh your registration details.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(HAA.Colors.muted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.lg))
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - QR Code
struct QRCodeImageView: View {
    let text: String

    var body: some View {
        if let image = generateQRCode(from: text) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            RoundedRectangle(cornerRadius: HAA.Radius.md)
                .fill(HAA.Colors.orangeLight)
                .overlay(
                    Image(systemName: "qrcode")
                        .font(.system(size: 48))
                        .foregroundColor(HAA.Colors.muted)
                )
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        guard let data = string.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let output = filter.outputImage else { return nil }

        let scale = 12.0
        let transformed = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let context = CIContext()

        guard let cgImage = context.createCGImage(transformed, from: transformed.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
