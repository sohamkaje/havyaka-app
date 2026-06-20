import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var profile = AttendeeProfile()
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var isSendingCode = false
    @Published var errorMessage: String?
    @Published var infoMessage: String?

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

    var displayName: String {
        let name = "\(profile.firstName) \(profile.lastName)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? profile.email : name
    }

    func sendLoginCode(email: String) {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter the registrant email address."
            return
        }

        isSendingCode = true
        errorMessage = nil
        infoMessage = nil

        Task {
            do {
                infoMessage = try await RegistrationAPI.sendLoginCode(email: trimmed)
            } catch {
                errorMessage = error.localizedDescription
            }
            isSendingCode = false
        }
    }

    func login(email: String, code: String) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            errorMessage = "Please enter the registrant email address."
            return
        }

        guard trimmedCode.count == 5, trimmedCode.allSatisfy(\.isNumber) else {
            errorMessage = "Please enter your 5-digit login code."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                var loaded = try await RegistrationAPI.login(email: trimmedEmail, code: trimmedCode)
                loaded.isLoggedIn = true
                profile = loaded
                save()
                isLoggedIn = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func logout() {
        profile = AttendeeProfile()
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: profileKey)
    }

    /// Polls the server for updated registration status. Returns true when the user was just checked in.
    @discardableResult
    func refreshRegistrationStatus() async -> Bool {
        let email = profile.email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isLoggedIn, !email.isEmpty else { return false }

        do {
            let updated = try await RegistrationAPI.fetchStatus(email: email)
            let wasCheckedIn = profile.hasCheckedIn

            profile.firstName = updated.firstName
            profile.lastName = updated.lastName
            profile.registrationId = updated.registrationId
            if !updated.registrationUuid.isEmpty {
                profile.registrationUuid = updated.registrationUuid
            }
            profile.hasCheckedIn = updated.hasCheckedIn
            save()

            return !wasCheckedIn && updated.hasCheckedIn
        } catch {
            return false
        }
    }

    func markCheckedInFromVolunteerScan() {
        infoMessage = "You're checked in. Welcome to the convention!"
    }
}
