import Foundation
import JavaScriptCore

public class OramaSwift {
    private let jsContext: JSContext
    private var orama: JSValue

    public init() throws {
        guard let jsContext = JSContext() else {
            throw OramaSwiftError.failedToCreateJSContext
        }
        self.jsContext = jsContext

        // Set up error handling
        jsContext.exceptionHandler = { context, exception in
            print("JavaScript Error: \(exception?.toString() ?? "Unknown error")")
        }

        guard
            let jsURL = Bundle.module.url(
                forResource: "index.global", withExtension: "js", subdirectory: "Resources")
        else {
            throw OramaSwiftError.jsFileNotFound
        }

        let jsCode = try String(contentsOf: jsURL, encoding: .utf8)
        jsContext.evaluateScript(jsCode)

        guard let orama = jsContext.objectForKeyedSubscript("Orama") else {
            throw OramaSwiftError.jsExecutionError("Failed to find OramaSwift in JavaScript context")
        }

        self.orama = orama
    }

    public func helloWorld() throws -> String {
        guard let helloWorld = orama.objectForKeyedSubscript("helloWorld") else {
            throw OramaSwiftError.jsExecutionError(
                "Failed to find helloWorld function in JavaScript context")
        }

        guard let result = helloWorld.call(withArguments: []) else {
            throw OramaSwiftError.jsExecutionError("Failed to execute helloWorld function")
        }

        guard let resultString = result.toString() else {
            throw OramaSwiftError.jsExecutionError("Failed to convert result to string")
        }

        return resultString
    }

    // withCheckedThrowingContinuation needs to be scoped in an @available block
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func helloWorldAsync() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            // Create resolve callback
            let resolveCallback: @convention(block) (JSValue) -> Void = { result in
                guard let resultString = result.toString() else {
                    continuation.resume(
                        throwing: OramaSwiftError.jsExecutionError("Failed to convert result to string"))
                    return
                }

                continuation.resume(returning: resultString)
            }

            // Create reject callback
            let rejectCallback: @convention(block) (JSValue) -> Void = { error in
                let errorMessage = error.toString() ?? "Unknown error"
                continuation.resume(throwing: OramaSwiftError.jsExecutionError(errorMessage))
            }

            // Convert callbacks to JSValue and call the promise
            let promiseArgs = [
                unsafeBitCast(resolveCallback, to: JSValue.self),
                unsafeBitCast(rejectCallback, to: JSValue.self),
            ]

            let promise = orama.objectForKeyedSubscript("helloWorldAsync").call(withArguments: [])
            promise?.invokeMethod("then", withArguments: promiseArgs)
        }
    }
}

public enum OramaSwiftError: Error {
    case failedToCreateJSContext
    case bundleNotFound
    case jsFileNotFound
    case jsExecutionError(String)

    public var localizedDescription: String {
        switch self {
        case .failedToCreateJSContext:
            return "Failed to create JavaScript context"
        case .bundleNotFound:
            return "Bundle not found"
        case .jsFileNotFound:
            return "JavaScript file not found in bundle resources"
        case .jsExecutionError(let message):
            return "JavaScript execution error: \(message)"
        }
    }
}
