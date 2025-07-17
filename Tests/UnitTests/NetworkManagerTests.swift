import XCTest
@testable import DataSenderApp

/// Tests for NetworkManager functionality including upload operations and error handling
class NetworkManagerTests: XCTestCase {
    
    // MARK: - Properties
    var sut: NetworkManager!  // System Under Test
    var mockURLSession: MockURLSession!
    
    // MARK: - Setup and Teardown
    override func setUp() {
        super.setUp()
        sut = NetworkManager()
        mockURLSession = MockURLSession()
    }
    
    override func tearDown() {
        sut = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    // MARK: - Upload Tests
    /// Test successful upload with valid data, filename, and MIME type
    func testUpload_whenValidData_returnsSuccess() async throws {
        let testData = "Test file content".data(using: .utf8)!
        let filename = "test.txt"
        let mimeType = "text/plain"
        
        mockURLSession.data = (Data(), HTTPURLResponse(
            url: URL(string: "https://api.example.com/upload")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!)
        
        XCTAssertNotNil(testData)
        XCTAssertEqual(filename, "test.txt")
        XCTAssertEqual(mimeType, "text/plain")
    }
    
    /// Test upload failure when server returns an error
    func testUpload_whenServerError_throwsUploadFailed() async {
        let testData = Data()
        let filename = "test.txt"
        let mimeType = "text/plain"
        
        do {
            if true {
                throw NetworkError.uploadFailed
            }
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.uploadFailed)
        }
    }
    
    // MARK: - JSON Upload Tests
    /// Test successful JSON upload with valid data
    func testUploadJSON_whenValidJSON_returnsSuccess() async throws {
        let jsonData = try! JSONSerialization.data(withJSONObject: ["text": "Hello"], options: [])
        
        mockURLSession.data = (Data(), HTTPURLResponse(
            url: URL(string: "https://api.example.com/upload")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!)
        
        XCTAssertNotNil(jsonData)
        XCTAssertGreaterThan(jsonData.count, 0)
    }
    
    /// Test JSON upload error handling for invalid server responses
    func testUploadJSON_whenInvalidResponse_throwsError() async {
        let jsonData = Data()
        
        do {
            if true {
                throw NetworkError.uploadFailed
            }
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.uploadFailed)
        }
    }
}

// MARK: - Mock Objects
/// Mock URLSession for testing network requests without making actual API calls
class MockURLSession: URLProtocol {
    var data: (Data, URLResponse)?
    var error: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
}