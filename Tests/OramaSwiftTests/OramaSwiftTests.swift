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

@Test func testCreateDatabase() async throws {
    let orama = try OramaSwift()

    // Define a simple schema
    let options: [String: Any] = [
        "schema": [
            "title": "string",
            "content": "string",
        ]
    ]

    // Create the database
    try orama.create(options: options)

    // Verify that the database was created
    #expect(orama.dbInitialized() == true)
}

@Test func testClearDatabase() async throws {
    let orama = try OramaSwift()

    // Define a simple schema
    let options: [String: Any] = [
        "schema": [
            "title": "string",
            "content": "string",
        ]
    ]

    // Create the database
    try orama.create(options: options)

    // Verify that the database is cleared
    #expect(orama.dbInitialized() == true)

    // Clear the database
    try orama.clear()

    // Verify that the database is cleared
    #expect(orama.dbInitialized() == false)
}

@Test func testInsertAndSearch() async throws {
    let orama = try OramaSwift()

    // Define a simple schema
    let options: [String: Any] = [
        "schema": [
            "title": "string",
            "content": "string",
        ]
    ]

    // Create the database
    try orama.create(options: options)

    // Insert a document
    let doc1: [String: Any] = [
        "title": "Foo",
        "content": "this is a foo document",
    ]
    try orama.insert(doc1)

    // Insert another document
    let doc2: [String: Any] = [
        "title": "Bar",
        "content": "this is a bar document",
    ]
    try orama.insert(doc2)

    // Search for the document
    let query: [String: Any] = [
        "term": "bar"
    ]
    let result = try orama.search(query)

    print(result)

    // Verify that the search result contains the inserted document
    #expect(result["count"] as? Int == 1)
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
@Test func testPersistData() async throws {
    let orama = try OramaSwift()

    // Define a simple schema
    let options: [String: Any] = [
        "schema": [
            "title": "string",
            "content": "string",
        ]
    ]

    // Create the database
    try orama.create(options: options)

    // Insert some test documents
    let doc1: [String: Any] = [
        "title": "Test Document 1",
        "content": "This is the first test document",
    ]
    try orama.insert(doc1)

    let doc2: [String: Any] = [
        "title": "Test Document 2", 
        "content": "This is the second test document",
    ]
    try orama.insert(doc2)

    // Persist the data
    let persistedData = try orama.persist()

    print(persistedData)

    // Verify that we got a JSON string back
    #expect(!persistedData.isEmpty)
}

@Test func testPersistAndRestore() async throws {
    // First, create a database and add some data
    let orama1 = try OramaSwift()

    let options: [String: Any] = [
        "schema": [
            "title": "string",
            "content": "string",
        ]
    ]

    try orama1.create(options: options)

    let doc1: [String: Any] = [
        "title": "Original Document 1",
        "content": "This is the first original document",
    ]
    try orama1.insert(doc1)

    let doc2: [String: Any] = [
        "title": "Original Document 2",
        "content": "This is the second original document",
    ]
    try orama1.insert(doc2)

    // Persist the data
    let persistedData = try orama1.persist()
    #expect(!persistedData.isEmpty)

    // Now create a new OramaSwift instance and restore the data
    let orama2 = try OramaSwift()
    
    // Restore the data
    try orama2.restore(dataString: persistedData)
    
    // Verify the database is initialized after restore
    #expect(orama2.dbInitialized() == true)

    // Search for the restored data
    let query: [String: Any] = [
        "term": "original"
    ]
    let result = try orama2.search(query)

    print("Restore test result:", result)

    // Verify that the search result contains the restored documents
    #expect(result["count"] as? Int == 2)
}
