import XCTest
@testable import DataSenderApp

class AppStateTests: XCTestCase {
    
    func testAppStateInitialization() {
        let appState = AppState()
        
        XCTAssertNotNil(appState.supabase)
    }
    
    func testSecretsManagerPlaceholderValues() {
        #if DEBUG
        XCTAssertEqual(SecretsManager.supabaseUrl, "https://example.supabase.co")
        XCTAssertEqual(SecretsManager.supabaseKey, "placeholder-key")
        #endif
    }
}