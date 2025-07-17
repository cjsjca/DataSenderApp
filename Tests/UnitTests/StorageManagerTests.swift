import XCTest
import Supabase
@testable import DataSenderApp

/// Tests for StorageManager functionality including file uploads and text storage
class StorageManagerTests: XCTestCase {
    
    // MARK: - Properties
    var sut: StorageManager!  // System Under Test
    var mockSupabaseClient: MockSupabaseClient!
    
    // MARK: - Setup and Teardown
    override func setUp() {
        super.setUp()
        mockSupabaseClient = MockSupabaseClient()
        sut = StorageManager(supabase: mockSupabaseClient)
    }
    
    override func tearDown() {
        sut = nil
        mockSupabaseClient = nil
        super.tearDown()
    }
    
    // MARK: - File Upload Tests
    /// Test successful file upload with valid data returns expected path format
    func testUploadFile_whenValidData_returnsPath() async throws {
        let testData = "Test content".data(using: .utf8)!
        let filename = "test.txt"
        let mimeType = "text/plain"
        let expectedPath = UUID().uuidString + "-" + filename
        
        mockSupabaseClient.mockUploadResponse = expectedPath
        let result = try await sut.uploadFile(testData, filename: filename, mimeType: mimeType)
        
        XCTAssertTrue(result.contains(filename))
        XCTAssertTrue(result.contains("-"))
    }
    
    /// Test file upload handles empty data gracefully
    func testUploadFile_whenEmptyData_returnsPath() async throws {
        let testData = Data()
        let filename = "empty.txt"
        let mimeType = "text/plain"
        
        let result = try await sut.uploadFile(testData, filename: filename, mimeType: mimeType)
        
        XCTAssertTrue(result.contains(filename))
    }
    
    // MARK: - Text Upload Tests
    /// Test successful text upload to database
    func testUploadText_whenValidText_completesSuccessfully() async throws {
        let testText = "Hello, World!"
        mockSupabaseClient.mockTextUploadSuccess = true
        
        try await sut.uploadText(testText)
        
        XCTAssertEqual(mockSupabaseClient.lastUploadedText, testText)
    }
    
    /// Test text upload handles empty strings
    func testUploadText_whenEmptyText_completesSuccessfully() async throws {
        let testText = ""
        mockSupabaseClient.mockTextUploadSuccess = true
        
        try await sut.uploadText(testText)
        
        XCTAssertEqual(mockSupabaseClient.lastUploadedText, testText)
    }
    
    // MARK: - Large File Tests
    /// Test upload of large files (10MB) to ensure proper handling
    func testUploadFile_whenLargeFile_returnsPath() async throws {
        let largeData = Data(repeating: 0, count: 10_000_000)
        let filename = "large.bin"
        let mimeType = "application/octet-stream"
        
        let result = try await sut.uploadFile(largeData, filename: filename, mimeType: mimeType)
        
        XCTAssertTrue(result.contains(filename))
        XCTAssertFalse(result.isEmpty)
    }
}

// MARK: - Mock Objects
/// Mock Supabase client for testing without making actual API calls
class MockSupabaseClient: SupabaseClient {
    var mockUploadResponse: String = "mock-path"
    var mockTextUploadSuccess = true
    var lastUploadedText: String?
    
    init() {
        super.init(
            supabaseURL: URL(string: "https://example.supabase.co")!,
            supabaseKey: "dummy-key"
        )
    }
    
    override var storage: SupabaseStorageClient {
        return MockStorageClient(uploadResponse: mockUploadResponse)
    }
    
    override var database: PostgrestClient {
        return MockPostgrestClient(uploadSuccess: mockTextUploadSuccess) { [weak self] text in
            self?.lastUploadedText = text
        }
    }
}

/// Mock storage client for testing file upload operations
class MockStorageClient: SupabaseStorageClient {
    let uploadResponse: String
    
    init(uploadResponse: String) {
        self.uploadResponse = uploadResponse
        super.init(url: URL(string: "https://example.com")!, headers: [:])
    }
}

/// Mock database client for testing database operations
class MockPostgrestClient: PostgrestClient {
    let uploadSuccess: Bool
    let textCallback: (String) -> Void
    
    init(uploadSuccess: Bool, textCallback: @escaping (String) -> Void) {
        self.uploadSuccess = uploadSuccess
        self.textCallback = textCallback
        super.init(url: URL(string: "https://example.com")!, schema: nil, headers: [:])
    }
}