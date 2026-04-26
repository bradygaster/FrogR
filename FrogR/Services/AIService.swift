import Foundation

/// Errors that can occur in the AI service layer.
enum AIServiceError: Error, LocalizedError {
    case missingToken
    case invalidRequestBody
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int, body: String?)
    case rateLimitExhausted
    case decodingError

    var errorDescription: String? {
        switch self {
        case .missingToken:
            return "GitHub token not found in Info.plist. Set GITHUB_TOKEN in Secrets.xcconfig."
        case .invalidRequestBody:
            return "Failed to serialize the request body to JSON."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "The server returned an invalid or unexpected response."
        case .httpError(let code, let body):
            return "HTTP \(code): \(body ?? "No details")"
        case .rateLimitExhausted:
            return "Rate limit exceeded on all models after maximum retries."
        case .decodingError:
            return "Failed to decode the response JSON."
        }
    }
}

/// Production implementation of `AIServiceProtocol` that calls the GitHub Models API.
final class AIService: AIServiceProtocol {

    private let session: URLSession
    private let token: String

    /// Creates an `AIService` reading `GITHUB_TOKEN` from the app's Info.plist.
    /// - Parameter session: URLSession to use (injectable for testing).
    init(session: URLSession = .shared) throws {
        guard let token = Bundle.main.infoDictionary?["GITHUB_TOKEN"] as? String,
              !token.isEmpty else {
            throw AIServiceError.missingToken
        }
        self.token = token
        self.session = session
    }

    /// Internal initializer that accepts a token directly (useful for testing).
    init(token: String, session: URLSession = .shared) {
        self.token = token
        self.session = session
    }

    // MARK: - AIServiceProtocol

    func chatCompletion(messages: [[String: Any]], model: String?) async throws -> [String: Any] {
        let body: [String: Any] = [
            "model": model ?? AIServiceConfig.defaultModel,
            "messages": messages
        ]
        return try await performWithFallback(body: body, preferredModel: model)
    }

    func chatCompletionWithVision(messages: [[String: Any]], imageData: Data?, model: String?) async throws -> [String: Any] {
        var processedMessages = messages

        // If image data is provided, append it as a base64 image_url part to the last user message.
        if let imageData = imageData {
            let base64 = imageData.base64EncodedString()
            let imageURL = "data:image/png;base64,\(base64)"

            let imagePart: [String: Any] = [
                "type": "image_url",
                "image_url": ["url": imageURL]
            ]

            if let lastIndex = processedMessages.lastIndex(where: { ($0["role"] as? String) == "user" }) {
                let existingContent = processedMessages[lastIndex]["content"]

                var contentArray: [[String: Any]] = []

                if let textContent = existingContent as? String {
                    contentArray.append(["type": "text", "text": textContent])
                } else if let arrayContent = existingContent as? [[String: Any]] {
                    contentArray = arrayContent
                }

                contentArray.append(imagePart)
                processedMessages[lastIndex]["content"] = contentArray
            } else {
                // No user message found; create one with just the image.
                processedMessages.append([
                    "role": "user",
                    "content": [imagePart]
                ])
            }
        }

        let body: [String: Any] = [
            "model": model ?? AIServiceConfig.defaultModel,
            "messages": processedMessages
        ]
        return try await performWithFallback(body: body, preferredModel: model)
    }

    // MARK: - Retry & Fallback

    /// Attempts the request with fallback model switching on persistent rate limits.
    private func performWithFallback(body: [String: Any], preferredModel: String?) async throws -> [String: Any] {
        let primary = preferredModel ?? AIServiceConfig.defaultModel
        var modelsToTry = AIServiceConfig.fallbackModels
        // Ensure the preferred model is tried first and not duplicated.
        modelsToTry.removeAll { $0 == primary }
        modelsToTry.insert(primary, at: 0)

        for model in modelsToTry {
            var attempt = body
            attempt["model"] = model

            do {
                return try await performWithRetry(body: attempt)
            } catch AIServiceError.rateLimitExhausted {
                // Try the next fallback model.
                continue
            }
        }

        throw AIServiceError.rateLimitExhausted
    }

    /// Retries a single request up to `maxRetries` times with exponential backoff + jitter.
    private func performWithRetry(body: [String: Any]) async throws -> [String: Any] {
        var lastError: Error = AIServiceError.invalidResponse

        for attempt in 0..<AIServiceConfig.maxRetries {
            do {
                return try await performRequest(body: body)
            } catch AIServiceError.httpError(let statusCode, _) where statusCode == 429 || (500...599).contains(statusCode) {
                lastError = AIServiceError.httpError(statusCode: statusCode, body: nil)
                let delay = calculateBackoff(attempt: attempt)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            } catch {
                throw error
            }
        }

        // If we exhausted retries due to rate limiting, signal for fallback.
        if case AIServiceError.httpError(let code, _) = lastError, code == 429 {
            throw AIServiceError.rateLimitExhausted
        }
        throw lastError
    }

    /// Calculates exponential backoff with random jitter.
    func calculateBackoff(attempt: Int) -> TimeInterval {
        let base = AIServiceConfig.baseDelay * pow(2.0, Double(attempt))
        let capped = min(base, AIServiceConfig.maxDelay)
        let jitter = Double.random(in: 0...(capped * 0.25))
        return capped + jitter
    }

    // MARK: - Network

    /// Performs a single HTTP request to the GitHub Models API.
    private func performRequest(body: [String: Any]) async throws -> [String: Any] {
        guard JSONSerialization.isValidJSONObject(body) else {
            throw AIServiceError.invalidRequestBody
        }

        let jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw AIServiceError.invalidRequestBody
        }

        var request = URLRequest(url: AIServiceConfig.endpoint, timeoutInterval: AIServiceConfig.timeout)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw AIServiceError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let bodyString = String(data: data, encoding: .utf8)
            throw AIServiceError.httpError(statusCode: httpResponse.statusCode, body: bodyString)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AIServiceError.decodingError
        }

        return json
    }
}
