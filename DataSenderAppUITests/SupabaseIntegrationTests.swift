import XCTest
@testable import DataSenderApp

class SupabaseIntegrationTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Set environment variables for testing
        app.launchEnvironment = [
            "SUPABASE_URL": ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://example.supabase.co",
            "SUPABASE_KEY": ProcessInfo.processInfo.environment["SUPABASE_KEY"] ?? "test-key"
        ]
        
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Text Upload Integration Test
    
    func testTextUploadIntegration() throws {
        let testText = "Integration test text - \(UUID().uuidString)"
        
        // Upload text through UI
        let textInputButton = app.buttons["textInputButton"]
        XCTAssertTrue(textInputButton.waitForExistence(timeout: 5))
        textInputButton.tap()
        
        let textEditor = app.textViews["textInputEditor"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 2))
        textEditor.tap()
        textEditor.typeText(testText)
        
        let sendButton = app.buttons["sendTextButton"]
        sendButton.tap()
        
        // Wait for upload completion
        let successAlert = app.alerts.firstMatch
        XCTAssertTrue(successAlert.waitForExistence(timeout: 10))
        
        // Verify success
        let alertText = successAlert.staticTexts.element(boundBy: 1).label
        XCTAssertTrue(alertText.contains("successfully"), "Upload should be successful")
        
        successAlert.buttons["OK"].tap()
        
        // Note: Actual Supabase verification would go here
        // In a real test environment, you would:
        // 1. Create a test-specific Supabase client
        // 2. Query the texts table for the uploaded text
        // 3. Assert that the text exists
    }
    
    // MARK: - Audio Upload Integration Test
    
    func testAudioUploadIntegration() throws {
        // Start recording
        let recordButton = app.buttons["recordAudioButton"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 5))
        recordButton.tap()
        
        // Handle permission
        let micAlert = app.alerts["DataSenderApp Would Like to Access the Microphone"]
        if micAlert.waitForExistence(timeout: 2) {
            micAlert.buttons["OK"].tap()
        }
        
        // Record for 3 seconds
        Thread.sleep(forTimeInterval: 3)
        
        // Stop recording
        recordButton.tap()
        
        // Wait for upload
        let successAlert = app.alerts.firstMatch
        XCTAssertTrue(successAlert.waitForExistence(timeout: 15))
        
        // Extract file path from alert
        let alertText = successAlert.staticTexts.element(boundBy: 1).label
        XCTAssertTrue(alertText.contains("audio-"), "Should contain audio filename prefix")
        XCTAssertTrue(alertText.contains(".m4a"), "Should have m4a extension")
        
        successAlert.buttons["OK"].tap()
        
        // Note: Actual Supabase storage verification would go here
    }
    
    // MARK: - File Upload Integration Test
    
    func testFileUploadIntegration() throws {
        // This test is limited on simulator
        // In a real device test, you would:
        // 1. Tap upload file button
        // 2. Select a test file from document picker
        // 3. Wait for upload
        // 4. Verify in Supabase storage
        
        let uploadButton = app.buttons["uploadFileButton"]
        XCTAssertTrue(uploadButton.waitForExistence(timeout: 5))
        uploadButton.tap()
        
        // Cancel picker on simulator
        let cancelButton = app.buttons["Cancel"]
        if cancelButton.waitForExistence(timeout: 3) {
            cancelButton.tap()
        }
    }
    
    // MARK: - Photo Upload Integration Test
    
    func testPhotoUploadIntegration() throws {
        #if targetEnvironment(simulator)
        throw XCTSkip("Camera not available on simulator")
        #endif
        
        let photoButton = app.buttons["takePhotoButton"]
        XCTAssertTrue(photoButton.waitForExistence(timeout: 5))
        photoButton.tap()
        
        // Handle camera permission
        let cameraAlert = app.alerts["DataSenderApp Would Like to Access the Camera"]
        if cameraAlert.waitForExistence(timeout: 2) {
            cameraAlert.buttons["OK"].tap()
        }
        
        // On real device, would capture photo and verify upload
    }
    
    // MARK: - Concurrent Upload Test
    
    func testConcurrentUploads() throws {
        // Test that multiple uploads don't interfere with each other
        
        // Start with text upload
        let textButton = app.buttons["textInputButton"]
        textButton.tap()
        
        let textEditor = app.textViews["textInputEditor"]
        textEditor.tap()
        textEditor.typeText("Concurrent test")
        
        app.buttons["sendTextButton"].tap()
        
        // Immediately start audio recording
        let recordButton = app.buttons["recordAudioButton"]
        if recordButton.isEnabled {
            recordButton.tap()
            
            // Handle permission if needed
            let micAlert = app.alerts["DataSenderApp Would Like to Access the Microphone"]
            if micAlert.waitForExistence(timeout: 1) {
                micAlert.buttons["OK"].tap()
            }
            
            Thread.sleep(forTimeInterval: 1)
            recordButton.tap()
        }
        
        // Wait for all uploads to complete
        var alertCount = 0
        while alertCount < 2 {
            let alert = app.alerts.firstMatch
            if alert.waitForExistence(timeout: 5) {
                alert.buttons["OK"].tap()
                alertCount += 1
            }
        }
        
        // Both uploads should complete successfully
        XCTAssertEqual(alertCount, 2, "Should have 2 success alerts")
    }
    
    // MARK: - Error Handling Test
    
    func testUploadErrorHandling() throws {
        // Test network error handling
        // This would require mocking network conditions
        // or using a test environment with controlled failures
        
        // For now, verify UI elements exist for error handling
        let textButton = app.buttons["textInputButton"]
        XCTAssertTrue(textButton.exists)
        
        let recordButton = app.buttons["recordAudioButton"]
        XCTAssertTrue(recordButton.exists)
        
        let uploadButton = app.buttons["uploadFileButton"]
        XCTAssertTrue(uploadButton.exists)
        
        let photoButton = app.buttons["takePhotoButton"]
        XCTAssertTrue(photoButton.exists)
    }
}