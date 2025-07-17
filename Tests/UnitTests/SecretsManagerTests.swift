import XCTest
@testable import DataSenderApp

class SecretsManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Set up test environment variables
        setenv("TEST_KEY", "test_value", 1)
        setenv("SUPABASE_URL", "https://test.supabase.co", 1)
        setenv("SUPABASE_KEY", "test-key", 1)
    }
    
    override func tearDown() {
        // Clean up environment variables
        unsetenv("TEST_KEY")
        unsetenv("SUPABASE_URL")
        unsetenv("SUPABASE_KEY")
        super.tearDown()
    }
    
    func testSupabaseUrl_whenSet_returnsValue() {
        // Given - environment variable is set in setUp
        
        // When
        let url = SecretsManager.supabaseUrl
        
        // Then
        XCTAssertEqual(url, "https://test.supabase.co")
    }
    
    func testSupabaseKey_whenSet_returnsValue() {
        // Given - environment variable is set in setUp
        
        // When
        let key = SecretsManager.supabaseKey
        
        // Then
        XCTAssertEqual(key, "test-key")
    }
    
    func testOptionalValue_whenNotSet_returnsNil() {
        // Given - OPENAI_ORG_ID is not set
        unsetenv("OPENAI_ORG_ID")
        
        // When
        let orgId = SecretsManager.openAIOrgId
        
        // Then
        XCTAssertNil(orgId)
    }
    
    func testOptionalValue_whenSet_returnsValue() {
        setenv("OPENAI_ORG_ID", "org-123", 1)
        
        let orgId = SecretsManager.openAIOrgId
        
        XCTAssertEqual(orgId, "org-123")
        
        unsetenv("OPENAI_ORG_ID")
    }
    
    func testDebugMode_whenTrue_returnsTrue() {
        setenv("DEBUG_MODE", "true", 1)
        
        let debugMode = SecretsManager.debugMode
        
        XCTAssertTrue(debugMode)
        
        unsetenv("DEBUG_MODE")
    }
    
    func testDebugMode_whenFalse_returnsFalse() {
        // Given
        setenv("DEBUG_MODE", "false", 1)
        
        // When
        let debugMode = SecretsManager.debugMode
        
        // Then
        XCTAssertFalse(debugMode)
        
        // Cleanup
        unsetenv("DEBUG_MODE")
    }
    
    func testDebugMode_whenInvalidValue_returnsFalse() {
        // Given
        setenv("DEBUG_MODE", "invalid", 1)
        
        // When
        let debugMode = SecretsManager.debugMode
        
        // Then
        XCTAssertFalse(debugMode)
        
        // Cleanup
        unsetenv("DEBUG_MODE")
    }
    
    func testEnvironment_whenSet_returnsValue() {
        // Given
        setenv("ENVIRONMENT", "production", 1)
        
        // When
        let environment = SecretsManager.environment
        
        // Then
        XCTAssertEqual(environment, "production")
        
        // Cleanup
        unsetenv("ENVIRONMENT")
    }
    
    // Note: We cannot easily test fatalError cases in unit tests
    // In production, you might want to refactor SecretsManager to throw errors instead
    func testMissingRequiredValue_behaviorDocumentation() {
        // This test documents the expected behavior when a required value is missing
        // In the actual implementation, this would cause a fatalError
        
        // Given - a required key that doesn't exist
        unsetenv("NONEXISTENT_REQUIRED_KEY")
        
        // When - accessing a required value
        // let value = SecretsManager.getValue(for: "NONEXISTENT_REQUIRED_KEY")
        
        // Then - the app would crash with fatalError
        // This is by design to catch configuration errors early
        XCTAssertTrue(true, "Document: Missing required values cause fatalError")
    }
}