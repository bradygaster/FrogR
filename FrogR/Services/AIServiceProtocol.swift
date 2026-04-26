import Foundation

/// Protocol defining the AI service interface for GitHub Models API integration.
/// All request/response bodies use `[String: Any]` dictionaries (JSONSerialization, not Codable).
protocol AIServiceProtocol: AnyObject {
    /// Send a chat completion request.
    /// - Parameters:
    ///   - messages: Array of message dictionaries with "role" and "content" keys.
    ///   - model: Optional model identifier. Defaults to `AIServiceConfig.defaultModel`.
    /// - Returns: Raw JSON response dictionary from the API.
    func chatCompletion(messages: [[String: Any]], model: String?) async throws -> [String: Any]

    /// Send a chat completion request with an optional image for vision models.
    /// - Parameters:
    ///   - messages: Array of message dictionaries.
    ///   - imageData: Optional image data to include as a base64-encoded image_url content part.
    ///   - model: Optional model identifier. Defaults to `AIServiceConfig.defaultModel`.
    /// - Returns: Raw JSON response dictionary from the API.
    func chatCompletionWithVision(messages: [[String: Any]], imageData: Data?, model: String?) async throws -> [String: Any]
}
