import Foundation

/// Mock implementation of `AIServiceProtocol` for previews and unit tests.
final class MockAIService: AIServiceProtocol {

    // MARK: - Configuration

    /// The canned response returned by all calls (override per-test).
    var stubbedResponse: [String: Any] = [
        "id": "mock-id",
        "object": "chat.completion",
        "choices": [
            [
                "index": 0,
                "message": [
                    "role": "assistant",
                    "content": "Mock response from AI service."
                ],
                "finish_reason": "stop"
            ]
        ]
    ]

    /// Set to a non-nil error to make the next call throw.
    var stubbedError: Error?

    /// Simulated async delay in seconds before returning. Default is 0 (instant).
    var simulatedDelay: TimeInterval = 0

    // MARK: - Call Tracking

    /// Total number of calls to either protocol method.
    private(set) var callCount = 0

    /// The messages array from the most recent call.
    private(set) var lastMessages: [[String: Any]]?

    /// The model string from the most recent call.
    private(set) var lastModel: String?

    /// The image data from the most recent vision call.
    private(set) var lastImageData: Data?

    // MARK: - AIServiceProtocol

    func chatCompletion(messages: [[String: Any]], model: String?) async throws -> [String: Any] {
        try await recordAndReturn(messages: messages, model: model, imageData: nil)
    }

    func chatCompletionWithVision(messages: [[String: Any]], imageData: Data?, model: String?) async throws -> [String: Any] {
        try await recordAndReturn(messages: messages, model: model, imageData: imageData)
    }

    // MARK: - Helpers

    /// Resets all tracking state.
    func reset() {
        callCount = 0
        lastMessages = nil
        lastModel = nil
        lastImageData = nil
        stubbedError = nil
        simulatedDelay = 0
    }

    private func recordAndReturn(messages: [[String: Any]], model: String?, imageData: Data?) async throws -> [String: Any] {
        callCount += 1
        lastMessages = messages
        lastModel = model
        lastImageData = imageData

        if simulatedDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }

        if let error = stubbedError {
            throw error
        }

        return stubbedResponse
    }
}
