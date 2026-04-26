import Foundation

/// Configuration constants for the AI service layer.
enum AIServiceConfig {
    /// GitHub Models API endpoint.
    static let endpoint = URL(string: "https://models.github.ai/inference/chat/completions")!

    /// Default model used when none is specified.
    static let defaultModel = "openai/gpt-4.1"

    /// Ordered fallback models tried when the primary model is rate-limited.
    static let fallbackModels = [
        "openai/gpt-4.1",
        "openai/gpt-4.1-mini",
        "openai/gpt-4.1-nano"
    ]

    /// Maximum number of retry attempts per model before falling back.
    static let maxRetries = 3

    /// Base delay in seconds for exponential backoff (doubled each retry).
    static let baseDelay: TimeInterval = 1.0

    /// Maximum delay cap in seconds for exponential backoff.
    static let maxDelay: TimeInterval = 16.0

    /// URLRequest timeout interval in seconds.
    static let timeout: TimeInterval = 30.0
}
