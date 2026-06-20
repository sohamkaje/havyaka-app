import Foundation

enum RegistrationAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodeFailed
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .invalidResponse:
            return "Unexpected server response."
        case .decodeFailed:
            return "Could not read server response. Please try again."
        case .server(let message):
            return message
        }
    }
}

struct APIRawResponse {
    let statusCode: Int
    let body: String
}

struct RegistrationAPI {
    static let baseURL = "https://havyak.org/api/auth.php"
    static let apiKey = ""

    static func sendLoginCode(email: String) async throws -> String {
        let raw = await postRaw(body: [
            "action": "sendcode",
            "email": email,
        ])

        let decoded = try decode(MessageEnvelope.self, from: raw)
        guard raw.statusCode == 200, decoded.success else {
            throw RegistrationAPIError.server(decoded.error ?? decoded.message ?? "Could not send login code.")
        }
        return decoded.message ?? "Login code sent to your email."
    }

    static func login(email: String, code: String) async throws -> AttendeeProfile {
        let raw = await postRaw(body: [
            "action": "login",
            "email": email,
            "code": code,
        ])

        let decoded: ProfileEnvelope
        do {
            decoded = try decode(ProfileEnvelope.self, from: raw)
        } catch {
            throw error
        }

        guard raw.statusCode == 200, decoded.success, let profile = decoded.profile else {
            throw RegistrationAPIError.server(decoded.error ?? "Login failed.")
        }

        return profile.toAttendeeProfile()
    }

    static func checkIn(email: String) async throws -> AttendeeProfile {
        let raw = await postRaw(body: [
            "action": "checkin",
            "email": email,
        ])

        let decoded: ProfileEnvelope
        do {
            decoded = try decode(ProfileEnvelope.self, from: raw)
        } catch {
            throw error
        }

        guard raw.statusCode == 200, decoded.success, let profile = decoded.profile else {
            throw RegistrationAPIError.server(decoded.error ?? "Check-in failed.")
        }

        return profile.toAttendeeProfile()
    }

    static func postRaw(body: [String: String]) async -> APIRawResponse {
        guard let url = URL(string: baseURL) else {
            return APIRawResponse(statusCode: 0, body: "Invalid API URL.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        }
        request.httpBody = try? JSONEncoder().encode(body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let bodyText = String(data: data, encoding: .utf8) ?? "(non-UTF8 response, \(data.count) bytes)"
            return APIRawResponse(statusCode: statusCode, body: bodyText)
        } catch {
            return APIRawResponse(statusCode: 0, body: "Network error: \(error.localizedDescription)")
        }
    }

    private static func decode<T: Decodable>(_ type: T.Type, from raw: APIRawResponse) throws -> T {
        guard let data = raw.body.data(using: .utf8), !data.isEmpty else {
            throw RegistrationAPIError.decodeFailed
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw RegistrationAPIError.decodeFailed
        }
    }
}

private struct MessageEnvelope: Decodable {
    let success: Bool
    let error: String?
    let message: String?
    let maskedEmail: String?
}

private struct ProfileEnvelope: Decodable {
    let success: Bool
    let error: String?
    let profile: APIProfile?
}

private struct APIProfile: Decodable {
    let firstName: String
    let lastName: String
    let email: String
    let role: String
    let registrationId: String?
    let hasCheckedIn: Bool?

    func toAttendeeProfile() -> AttendeeProfile {
        AttendeeProfile(
            firstName: firstName,
            lastName: lastName,
            email: email,
            role: AttendeeRole(rawValue: role) ?? .registrant,
            registrationId: registrationId ?? "",
            hasCheckedIn: hasCheckedIn ?? false,
            isLoggedIn: true
        )
    }
}
