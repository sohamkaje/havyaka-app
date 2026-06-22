import Foundation

enum PhotosAPIError: LocalizedError {
    case invalidURL
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid photos API URL."
        case .server(let message): return message
        }
    }
}

struct PhotosAPI {
    static let baseURL = "https://havyak.org/api/photos.php"

    static func fetchGallery() async throws -> [ConventionPhoto] {
        let envelope: GalleryEnvelope = try await postJSON(body: [
            "action": "list",
        ])

        guard envelope.success else {
            throw PhotosAPIError.server(envelope.error ?? "Could not load gallery.")
        }

        return envelope.photos?.map { $0.toConventionPhoto() } ?? []
    }

    static func upload(
        fileData: Data,
        fileName: String,
        mimeType: String,
        mediaType: PhotoMediaType,
        caption: String,
        day: String,
        eventTag: PhotoEventTag,
        uploadedBy: String,
        uploaderEmail: String
    ) async throws -> ConventionPhoto {
        if let sizeError = PhotosLimits.validateFileSize(Int64(fileData.count)) {
            throw PhotosAPIError.server(sizeError)
        }

        guard let url = URL(string: baseURL) else {
            throw PhotosAPIError.invalidURL
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func appendField(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        appendField("action", "upload")
        appendField("caption", caption)
        appendField("day", day)
        appendField("eventTag", eventTag.rawValue)
        appendField("uploadedBy", uploadedBy)
        appendField("uploaderEmail", uploaderEmail)
        appendField("mediaType", mediaType.rawValue)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw PhotosAPIError.server("Unexpected server response.")
        }

        let envelope = try JSONDecoder().decode(UploadEnvelope.self, from: data)
        guard http.statusCode == 200, envelope.success, let photo = envelope.photo else {
            throw PhotosAPIError.server(envelope.error ?? "Upload failed.")
        }

        return photo.toConventionPhoto()
    }

    static func delete(photoId: String, uploaderEmail: String) async throws {
        let envelope: ActionEnvelope = try await postJSON(body: [
            "action": "delete",
            "id": photoId,
            "uploaderEmail": uploaderEmail,
        ])

        guard envelope.success else {
            throw PhotosAPIError.server(envelope.error ?? "Could not delete photo.")
        }
    }

    private static func postJSON<T: Decodable>(body: [String: String]) async throws -> T {
        guard let url = URL(string: baseURL) else {
            throw PhotosAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard response is HTTPURLResponse else {
            throw PhotosAPIError.server("Unexpected server response.")
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

private struct GalleryEnvelope: Decodable {
    let success: Bool
    let error: String?
    let photos: [APIPhoto]?
}

private struct UploadEnvelope: Decodable {
    let success: Bool
    let error: String?
    let photo: APIPhoto?
}

private struct ActionEnvelope: Decodable {
    let success: Bool
    let error: String?
    let message: String?
}

private struct APIPhoto: Decodable {
    let id: String
    let mediaURL: String?
    let caption: String
    let uploadedBy: String
    let uploaderEmail: String?
    let day: String
    let eventTag: String
    let mediaType: String

    func toConventionPhoto() -> ConventionPhoto {
        ConventionPhoto(
            id: id,
            mediaURL: mediaURL,
            imageName: mediaType == PhotoMediaType.video.rawValue ? "play.rectangle.fill" : "photo.fill",
            caption: caption,
            uploadedBy: uploadedBy,
            uploaderEmail: uploaderEmail ?? "",
            day: day,
            eventTag: PhotoEventTag(rawValue: eventTag) ?? .general,
            mediaType: PhotoMediaType(rawValue: mediaType) ?? .image
        )
    }
}
