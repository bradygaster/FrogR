import XCTest
@testable import FrogR

final class AIServiceTests: XCTestCase {

    private var mock: MockAIService!

    override func setUp() {
        super.setUp()
        mock = MockAIService()
    }

    override func tearDown() {
        mock = nil
        super.tearDown()
    }

    // MARK: - Mock: Stubbed Response

    func testMockReturnsStubbedResponse() async throws {
        let expected: [String: Any] = [
            "id": "test-123",
            "choices": [["message": ["content": "Hello"]]]
        ]
        mock.stubbedResponse = expected

        let messages: [[String: Any]] = [["role": "user", "content": "Hi"]]
        let result = try await mock.chatCompletion(messages: messages, model: nil)

        XCTAssertEqual(result["id"] as? String, "test-123")
        let choices = result["choices"] as? [[String: Any]]
        XCTAssertNotNil(choices)
        XCTAssertEqual(choices?.count, 1)
    }

    // MARK: - Mock: Simulated Error

    func testMockThrowsStubbedError() async {
        mock.stubbedError = AIServiceError.rateLimitExhausted

        let messages: [[String: Any]] = [["role": "user", "content": "Hi"]]
        do {
            _ = try await mock.chatCompletion(messages: messages, model: nil)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is AIServiceError)
        }
    }

    // MARK: - Mock: Call Count Tracking

    func testMockTracksCallCount() async throws {
        let messages: [[String: Any]] = [["role": "user", "content": "Hi"]]

        _ = try await mock.chatCompletion(messages: messages, model: nil)
        _ = try await mock.chatCompletion(messages: messages, model: nil)
        _ = try await mock.chatCompletionWithVision(messages: messages, imageData: nil, model: nil)

        XCTAssertEqual(mock.callCount, 3)
    }

    // MARK: - Mock: Records Last Request

    func testMockRecordsLastMessages() async throws {
        let messages: [[String: Any]] = [
            ["role": "system", "content": "You are a helper."],
            ["role": "user", "content": "What is Frogger?"]
        ]

        _ = try await mock.chatCompletion(messages: messages, model: "openai/gpt-4.1-mini")

        XCTAssertEqual(mock.lastMessages?.count, 2)
        XCTAssertEqual(mock.lastMessages?.last?["content"] as? String, "What is Frogger?")
        XCTAssertEqual(mock.lastModel, "openai/gpt-4.1-mini")
    }

    // MARK: - Mock: Vision Records Image Data

    func testMockRecordsImageData() async throws {
        let messages: [[String: Any]] = [["role": "user", "content": "Describe this"]]
        let imageData = Data([0xFF, 0xD8, 0xFF, 0xE0])

        _ = try await mock.chatCompletionWithVision(messages: messages, imageData: imageData, model: nil)

        XCTAssertEqual(mock.lastImageData, imageData)
    }

    // MARK: - Mock: Reset

    func testMockReset() async throws {
        let messages: [[String: Any]] = [["role": "user", "content": "Hi"]]
        _ = try await mock.chatCompletion(messages: messages, model: "test-model")

        mock.reset()

        XCTAssertEqual(mock.callCount, 0)
        XCTAssertNil(mock.lastMessages)
        XCTAssertNil(mock.lastModel)
        XCTAssertNil(mock.lastImageData)
        XCTAssertNil(mock.stubbedError)
        XCTAssertEqual(mock.simulatedDelay, 0)
    }

    // MARK: - Config Defaults

    func testConfigDefaults() {
        XCTAssertEqual(AIServiceConfig.defaultModel, "openai/gpt-4.1")
        XCTAssertEqual(AIServiceConfig.maxRetries, 3)
        XCTAssertEqual(AIServiceConfig.baseDelay, 1.0)
        XCTAssertEqual(AIServiceConfig.maxDelay, 16.0)
        XCTAssertEqual(AIServiceConfig.timeout, 30.0)
        XCTAssertFalse(AIServiceConfig.fallbackModels.isEmpty)
    }

    // MARK: - Backoff Calculation

    func testExponentialBackoffValues() throws {
        let service = AIService(token: "fake-token")

        let delay0 = service.calculateBackoff(attempt: 0)
        // Base = 1.0 * 2^0 = 1.0, jitter up to 0.25 → range [1.0, 1.25]
        XCTAssertGreaterThanOrEqual(delay0, 1.0)
        XCTAssertLessThanOrEqual(delay0, 1.25)

        let delay1 = service.calculateBackoff(attempt: 1)
        // Base = 1.0 * 2^1 = 2.0, jitter up to 0.5 → range [2.0, 2.5]
        XCTAssertGreaterThanOrEqual(delay1, 2.0)
        XCTAssertLessThanOrEqual(delay1, 2.5)

        let delay2 = service.calculateBackoff(attempt: 2)
        // Base = 1.0 * 2^2 = 4.0, jitter up to 1.0 → range [4.0, 5.0]
        XCTAssertGreaterThanOrEqual(delay2, 4.0)
        XCTAssertLessThanOrEqual(delay2, 5.0)
    }

    func testBackoffCapsAtMaxDelay() throws {
        let service = AIService(token: "fake-token")

        let delay10 = service.calculateBackoff(attempt: 10)
        // 2^10 = 1024 → capped at 16.0, jitter up to 4.0 → max 20.0
        XCTAssertLessThanOrEqual(delay10, AIServiceConfig.maxDelay * 1.25)
    }

    // MARK: - Fallback Model Array

    func testFallbackModelsContainDefault() {
        XCTAssertTrue(AIServiceConfig.fallbackModels.contains(AIServiceConfig.defaultModel))
    }

    func testFallbackModelsOrdering() {
        let models = AIServiceConfig.fallbackModels
        XCTAssertEqual(models.count, 3)
        XCTAssertEqual(models[0], "openai/gpt-4.1")
        XCTAssertEqual(models[1], "openai/gpt-4.1-mini")
        XCTAssertEqual(models[2], "openai/gpt-4.1-nano")
    }

    // MARK: - Error Descriptions

    func testErrorDescriptions() {
        XCTAssertNotNil(AIServiceError.missingToken.errorDescription)
        XCTAssertNotNil(AIServiceError.rateLimitExhausted.errorDescription)
        XCTAssertNotNil(AIServiceError.invalidRequestBody.errorDescription)
        XCTAssertNotNil(AIServiceError.invalidResponse.errorDescription)
        XCTAssertNotNil(AIServiceError.decodingError.errorDescription)

        let httpError = AIServiceError.httpError(statusCode: 500, body: "Internal Server Error")
        XCTAssertTrue(httpError.errorDescription?.contains("500") ?? false)
    }

    // MARK: - Missing Token

    func testServiceThrowsOnMissingToken() {
        // Bundle.main won't have GITHUB_TOKEN in test, so init should throw.
        XCTAssertThrowsError(try AIService()) { error in
            XCTAssertTrue(error is AIServiceError)
            if case AIServiceError.missingToken = error {
                // Expected
            } else {
                XCTFail("Expected missingToken, got \(error)")
            }
        }
    }
}
