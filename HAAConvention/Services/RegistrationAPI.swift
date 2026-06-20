import Foundation

enum RegistrationAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodeFailed(String)
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .invalidResponse:
            return "Unexpected server response."
        case .decodeFailed(let detail):
            return "Could not read server response: \(detail)"
        case .server(let message):
            return message
        }
    }
}

struct APIRawResponse {
    let statusCode: Int
    let body: String

    var displayText: String {
        let bodyDisplay = body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "(empty body)"
            : body
        return "HTTP \(statusCode)\n\(bodyDisplay)"
    }
}

struct RegistrationAPI {
    static let baseURL = "https://havyak.org/api/auth.php"
    static let apiKey = ""

    static func sendLoginCode(email: String) async -> (raw: APIRawResponse, result: Result<String, Error>) {
        let raw = await postRaw(body: [
            "action": "sendcode",
            "email": email,
        ])

        do {
            let decoded = try decode(MessageEnvelope.self, from: raw)
            guard raw.statusCode == 200, decoded.success else {
                let message = decoded.error ?? decoded.message ?? "Could not send login code."
                return (raw, .failure(RegistrationAPIError.server(message)))
            }
            return (raw, .success(decoded.message ?? "Login code sent to your email."))
        } catch {
            return (raw, .failure(error))
        }
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
        guard let data = raw.body.data(using: .utf8) else {
            throw RegistrationAPIError.decodeFailed(raw.displayText)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw RegistrationAPIError.decodeFailed(raw.displayText)
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

    func toAttendeeProfile() -> AttendeeProfile {
        AttendeeProfile(
            firstName: firstName,
            lastName: lastName,
            email: email,
            role: AttendeeRole(rawValue: role) ?? .registrant,
            registrationId: registrationId ?? "",
            isLoggedIn: true
        )
    }
}
