import Testing

@testable import OramaSwift

@Test func testHelloWorld() throws {
    let orama = try OramaSwift()
    let result = try orama.helloWorld()
    #expect(result == "Hello World")
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
@Test func testHelloWorldAsync() async throws {
    let orama = try OramaSwift()
    let result = try await orama.helloWorldAsync()
    #expect(result == "Hello World")
}

@Test func testOramaSwiftInitialization() throws {
    // Test that OramaSwift can be initialized without throwing
    let orama = try OramaSwift()
    #expect(orama != nil)
}

@Test func testCreateDatabase() throws {
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

@Test func testClearDatabase() throws {
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

@Test func testInsertAndSearch() throws {
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
    #expect(result.count == 1)
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
@Test func testPersistData() throws {
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

@Test func testPersistAndRestore() throws {
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
    #expect(result.count == 2)
}

@Test func testGetByID() throws {
    let orama = try OramaSwift()

    // Define a simple schema
    let options: [String: Any] = [
        "schema": [
            "id": "string",
            "title": "string",
            "content": "string",
        ]
    ]

    // Create the database
    try orama.create(options: options)

    // Insert a document
    let doc: [String: Any] = [
        "id": "12345",
        "title": "Test Document",
        "content": "This is a test document",
    ]
    try orama.insert(doc)

    // Get the document by ID
    let result = try orama.getByID("12345")

    print(result)

    // Verify that the result matches the inserted document
    #expect(result["title"] as? String == "Test Document")
}

@Test func testCount() throws {
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

    // Insert some documents
    let doc1: [String: Any] = [
        "title": "Document 1",
        "content": "This is the first document",
    ]
    try orama.insert(doc1)

    let doc2: [String: Any] = [
        "title": "Document 2",
        "content": "This is the second document",
    ]
    try orama.insert(doc2)

    // Count the documents in the database
    let count = try orama.count()

    print("Document count:", count)

    // Verify that the count matches the number of inserted documents
    #expect(count == 2)
}

@Test func testMultilingual() throws {
    let orama = try OramaSwift()

    // Define a simple schema
    let schema: [AnyHashable: Any] = [
        "city": "string",
    ]

    let languages: [String] = ["es", "en", "zh"]

    // Create the database
    try orama.createMultilingual(schema: schema, languages: languages)

    // Insert documents in different languages
    let doc1: [String: Any] = [
        "city": "Barcelona, España",
    ]
    try orama.insert(doc1)

    let doc2: [String: Any] = [
        "city": "New York, United States",
    ]
    try orama.insert(doc2)

    let doc3: [String: Any] = [
        "city": "中国北京",
    ]
    try orama.insert(doc3)

    // Search for documents in different languages
    let querySpanish: [String: Any] = ["term": "España"]
    let resultSpanish = try orama.search(querySpanish)
    
    let queryEnglish: [String: Any] = ["term": "United"]
    let resultEnglish = try orama.search(queryEnglish)
    
    let queryChinese: [String: Any] = ["term": "北京"]
    let resultChinese = try orama.search(queryChinese)

    print("Spanish Result:", resultSpanish)
    print("English Result:", resultEnglish)
    print("Chinese Result:", resultChinese)

    // Verify that the search results contain the respective documents
    #expect(resultSpanish.count == 1)
    #expect(resultEnglish.count == 1)
    #expect(resultChinese.count == 1)
}

@Test func testRemove() throws {
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
    let doc: [String: Any] = [
        "title": "Document to Remove",
        "content": "This document will be removed",
    ]
    let docId = try orama.insert(doc)

    // Verify that the document exists
    let query: [String: Any] = ["term": "Remove"]
    let initialResult = try orama.search(query)
    #expect(initialResult.count == 1)

    // Remove the document
    try orama.remove(docId)

    // Verify that the document has been removed
    let finalResult = try orama.search(query)
    #expect(finalResult.count == 0)
}
