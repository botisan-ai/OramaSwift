import Foundation
import JavaScriptCore

public struct ElapsedTime {
    public var raw: Double
    public var formatted: String
}

public struct OramaSearchResult {
    public var id: String
    public var score: Double
    public var document: [AnyHashable: Any]
}

public struct OramaSearchResults {
    public var count: Int
    public var elapsed: ElapsedTime
    public var hits: [OramaSearchResult]

    // TODO: faceted search results and group results

    public static func emptyResults() -> OramaSearchResults {
        return OramaSearchResults(count: 0, elapsed: ElapsedTime(raw: 0, formatted: "0s"), hits: [])
    }
}

public class OramaSwift {
    private let jsContext: JSContext
    private var orama: JSValue
    private var breakIterator: JSValue
    private var db: JSValue?

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
                forResource: "index.global", withExtension: "js", subdirectory: "JavaScript")
        else {
            throw OramaSwiftError.jsFileNotFound
        }

        let jsCode = try String(contentsOf: jsURL, encoding: .utf8)
        jsContext.evaluateScript(jsCode)

        guard let orama = jsContext.objectForKeyedSubscript("orama") else {
            throw OramaSwiftError.jsExecutionError("Failed to find OramaSwift in JavaScript context")
        }

        self.orama = orama

        jsContext.setObject(BreakIterator.self, forKeyedSubscript: "BreakIterator" as NSString)

        guard let breakIteratorClass = jsContext.objectForKeyedSubscript("BreakIterator") else {
            throw OramaSwiftError.jsExecutionError("Failed to find BreakIterator class in JavaScript context")
        }

        guard let breakIterator = breakIteratorClass.invokeMethod("create", withArguments: []) else {
            throw OramaSwiftError.jsExecutionError("Failed to create BreakIterator instance")
        }

        jsContext.setObject(breakIterator, forKeyedSubscript: "breakIterator" as NSString)
        self.breakIterator = breakIterator

        // guard let result = breakIterator.invokeMethod("utf8BreakIteratorWithBreakTypeLocaleTextToBreak", withArguments: [Int32(1), "zh", "中国北京"]) else {
        //     throw OramaSwiftError.jsExecutionError("Failed to invoke utf8BreakIterator method")
        // }

        // print(result)
    }

    public func dbInitialized() -> Bool {
        return db != nil
    }

    public func clear() throws {
        if !dbInitialized() {
            throw OramaSwiftError.databaseNotInitialized
        }

        // set db to undefined in JS context
        jsContext.setObject(JSValue(undefinedIn: jsContext), forKeyedSubscript: "db" as NSString)
        db = nil
    }

    public func create(options: [AnyHashable: Any]) throws {
        if dbInitialized() {
            throw OramaSwiftError.databaseAlreadyInitialized
        }

        guard let db = orama.invokeMethod("create", withArguments: [options]) else {
            throw OramaSwiftError.jsExecutionError("Failed to create database")
        }

        jsContext.setObject(db, forKeyedSubscript: "db" as NSString)
        self.db = db
    }

    public func createMultilingual(schema: [AnyHashable: Any], languages: [String]) throws {
        if dbInitialized() {
            throw OramaSwiftError.databaseAlreadyInitialized
        }

        guard let createMultilingual = orama.objectForKeyedSubscript("createMultilingual") else {
            throw OramaSwiftError.jsExecutionError("Failed to find createMultilingual function in JavaScript context")
        }

        guard let db = createMultilingual.call(withArguments: [breakIterator, schema, languages]) else {
            throw OramaSwiftError.jsExecutionError("Failed to create multilingual database")
        }

        jsContext.setObject(db, forKeyedSubscript: "db" as NSString)
        self.db = db
    }

    public func restoreMultilingual(dataString: String, languages: [String]) throws {
        if dbInitialized() {
            throw OramaSwiftError.databaseAlreadyInitialized
        }

        guard let restoreMultilingual = orama.objectForKeyedSubscript("restoreMultilingual") else {
            throw OramaSwiftError.jsExecutionError("Failed to find restoreMultilingual function in JavaScript context")
        }

        guard let restoredDb = restoreMultilingual.call(withArguments: [breakIterator, languages, dataString]) else {
            throw OramaSwiftError.jsExecutionError("Failed to restore multilingual database")
        }

        jsContext.setObject(restoredDb, forKeyedSubscript: "db" as NSString)
        self.db = restoredDb
    }

    public func insert(_ doc: [AnyHashable: Any]) throws -> String {
        guard let db = db else {
            throw OramaSwiftError.databaseNotInitialized
        }

        return orama.invokeMethod("insert", withArguments: [db, doc]).toString()
    }

    public func upsert(_ doc: [AnyHashable: Any]) throws -> String {
        guard let db = db else {
            throw OramaSwiftError.databaseNotInitialized
        }

        return orama.invokeMethod("upsert", withArguments: [db, doc]).toString()
    }

    public func remove(_ id: String) throws {
        guard let db = db else {
            throw OramaSwiftError.databaseNotInitialized
        }

        orama.invokeMethod("remove", withArguments: [db, id])
    }

    public func search(_ query: [AnyHashable: Any]) throws -> OramaSearchResults {
        guard let db = db else {
            throw OramaSwiftError.databaseNotInitialized
        }

        guard let results = orama.invokeMethod("search", withArguments: [db, query]) else {
            throw OramaSwiftError.jsExecutionError("Failed to execute search")
        }

        guard let resultsDict = results.toDictionary() else {
            throw OramaSwiftError.jsExecutionError("Failed to convert search result to dictionary")
        }

        guard let count = resultsDict["count"] as? Int else {
            throw OramaSwiftError.jsExecutionError("Invalid search result format")
        }

        guard let elapsedDict = resultsDict["elapsed"] as? [AnyHashable: Any] else {
            throw OramaSwiftError.jsExecutionError("Invalid elapsed time format in search result")
        }

        guard let elapsedRaw = elapsedDict["raw"] as? Double,
              let elapsedFormatted = elapsedDict["formatted"] as? String else {
            throw OramaSwiftError.jsExecutionError("Invalid elapsed time format in search result")
        }

        let elapsedTime = ElapsedTime(raw: elapsedRaw, formatted: elapsedFormatted)

        guard let hitsArray = resultsDict["hits"] as? [[AnyHashable: Any]] else {
            throw OramaSwiftError.jsExecutionError("Invalid hits format in search result")
        }

        let hits = hitsArray.compactMap { hitDict -> OramaSearchResult? in
            guard let id = hitDict["id"] as? String,
                  let score = hitDict["score"] as? Double,
                  let document = hitDict["document"] as? [AnyHashable: Any] else {
                return nil
            }

            return OramaSearchResult(id: id, score: score, document: document)
        }

        return OramaSearchResults(count: count, elapsed: elapsedTime, hits: hits)
    }

    public func getByID(_ id: String) throws ->  [AnyHashable: Any]? {
        guard let db = db else {
            throw OramaSwiftError.databaseNotInitialized
        }

        guard let result = orama.invokeMethod("getByID", withArguments: [db, id]) else {
            throw OramaSwiftError.jsExecutionError("Failed to execute getByID")
        }

        // Check if result is nil
        if result.isUndefined || result.isNull {
            return nil
        }

        guard let resultDict = result.toDictionary() else {
            throw OramaSwiftError.jsExecutionError("Failed to convert getByID result to dictionary")
        }

        return resultDict
    }

    public func count() throws -> Int {
        guard let db = db else {
            throw OramaSwiftError.databaseNotInitialized
        }

        guard let result = orama.invokeMethod("count", withArguments: [db]) else {
            throw OramaSwiftError.jsExecutionError("Failed to execute count")
        }

        return Int(result.toInt32())
    }

    public func persist() throws -> String {
        guard let db = db else {
            throw OramaSwiftError.databaseNotInitialized
        }

        guard let result = orama.invokeMethod("persist", withArguments: [db]) else {
            throw OramaSwiftError.jsExecutionError("Failed to persist data")
        }

        guard let resultString = result.toString() else {
            throw OramaSwiftError.jsExecutionError("Failed to convert persistData result to string")
        }

        return resultString
    }

    public func restore(dataString: String) throws {
        if dbInitialized() {
            throw OramaSwiftError.databaseAlreadyInitialized
        }

        guard let restoredDb = orama.invokeMethod("restore", withArguments: [dataString]) else {
            throw OramaSwiftError.jsExecutionError("Failed to restore data")
        }

        jsContext.setObject(restoredDb, forKeyedSubscript: "db" as NSString)
        self.db = restoredDb
    }

    //  MARK: - Example JavaScript Function Calls

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
    case databaseNotInitialized
    case databaseAlreadyInitialized
    case jsExecutionError(String)

    public var localizedDescription: String {
        switch self {
        case .failedToCreateJSContext:
            return "Failed to create JavaScript context"
        case .bundleNotFound:
            return "Bundle not found"
        case .jsFileNotFound:
            return "JavaScript file not found in bundle resources"
        case .databaseNotInitialized:
            return "Database is not initialized"
        case .databaseAlreadyInitialized:
            return "Database already initialized"
        case .jsExecutionError(let message):
            return "JavaScript execution error: \(message)"
        }
    }
}
