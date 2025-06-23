import Testing
@testable import OramaSwift

@Test func testHelloWorld() async throws {
    let orama = try OramaSwift()
    let result = try orama.helloWorld()
    #expect(result == "Hello World")
}

@Test func testOramaSwiftInitialization() async throws {
    // Test that OramaSwift can be initialized without throwing
    let orama = try OramaSwift()
    #expect(orama != nil)
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
@Test func testHelloWorldAsync() async throws {
    let orama = try OramaSwift()
    let result = try await orama.helloWorldAsync()
    #expect(result == "Hello World")
}
