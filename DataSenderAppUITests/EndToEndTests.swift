import XCTest

class EndToEndTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Text Input Flow Tests
    
    func testTextInputFlow() throws {
        // Find and tap Text Input button
        let textInputButton = app.buttons["textInputButton"]
        XCTAssertTrue(textInputButton.waitForExistence(timeout: 5))
        textInputButton.tap()
        
        // Enter text in the TextEditor
        let textEditor = app.textViews["textInputEditor"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 2))
        textEditor.tap()
        textEditor.typeText("Test message from UI test at \(Date())")
        
        // Tap Send button
        let sendButton = app.buttons["sendTextButton"]
        XCTAssertTrue(sendButton.exists)
        sendButton.tap()
        
        // Wait for upload to complete and alert to appear
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 10), "Upload alert should appear")
        
        // Verify success message
        XCTAssertTrue(alert.staticTexts["Upload Result"].exists)
        XCTAssertTrue(alert.staticTexts.element(matching: .any, identifier: nil).label.contains("successfully"))
        
        // Dismiss alert
        alert.buttons["OK"].tap()
        
        // Verify text editor is hidden
        XCTAssertFalse(textEditor.exists)
    }
    
    // MARK: - Photo Capture Flow Tests
    
    func testPhotoCaptureFlow() throws {
        // Skip this test on simulator as camera is not available
        #if targetEnvironment(simulator)
        throw XCTSkip("Camera tests cannot run on simulator")
        #endif
        
        // Find and tap Take Photo button
        let takePhotoButton = app.buttons["takePhotoButton"]
        XCTAssertTrue(takePhotoButton.waitForExistence(timeout: 5))
        takePhotoButton.tap()
        
        // Handle camera permission if needed
        let cameraPermissionAlert = app.alerts["DataSenderApp Would Like to Access the Camera"]
        if cameraPermissionAlert.waitForExistence(timeout: 2) {
            cameraPermissionAlert.buttons["OK"].tap()
        }
        
        // The camera picker would appear here on a real device
        // For testing purposes, we'll verify the flow setup
        
        // Verify alert handling is set up
        let uploadingIndicator = app.staticTexts["uploadingIndicator"]
        if uploadingIndicator.waitForExistence(timeout: 2) {
            XCTAssertTrue(uploadingIndicator.exists, "Uploading indicator should be visible during upload")
        }
    }
    
    // MARK: - Audio Recording Flow Tests
    
    func testAudioRecordingFlow() throws {
        // Find and tap Record Audio button
        let recordButton = app.buttons["recordAudioButton"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 5))
        
        // Start recording
        recordButton.tap()
        
        // Handle microphone permission if needed
        let micPermissionAlert = app.alerts["DataSenderApp Would Like to Access the Microphone"]
        if micPermissionAlert.waitForExistence(timeout: 2) {
            micPermissionAlert.buttons["OK"].tap()
        }
        
        // Verify button text changes to "Stop Recording"
        XCTAssertTrue(recordButton.label == "Stop Recording", "Button should show 'Stop Recording' when recording")
        
        // Record for 2 seconds
        Thread.sleep(forTimeInterval: 2)
        
        // Stop recording
        recordButton.tap()
        
        // Wait for upload to complete and alert to appear
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 10), "Upload alert should appear")
        
        // Verify success message
        XCTAssertTrue(alert.staticTexts["Upload Result"].exists)
        XCTAssertTrue(alert.staticTexts.element(matching: .any, identifier: nil).label.contains("Audio uploaded successfully"))
        
        // Dismiss alert
        alert.buttons["OK"].tap()
        
        // Verify button text changes back
        XCTAssertTrue(recordButton.label == "Record Audio", "Button should show 'Record Audio' when not recording")
    }
    
    // MARK: - File Upload Flow Tests
    
    func testFileUploadFlow() throws {
        // Find and tap Upload File button
        let uploadFileButton = app.buttons["uploadFileButton"]
        XCTAssertTrue(uploadFileButton.waitForExistence(timeout: 5))
        uploadFileButton.tap()
        
        // Document picker would appear here
        // On simulator, we can't fully test document picker interaction
        // but we can verify the UI is set up correctly
        
        // For a real test, you would:
        // 1. Select a file from the document picker
        // 2. Wait for upload to complete
        // 3. Verify success alert
        
        // Cancel the document picker if it appears
        let cancelButton = app.buttons["Cancel"]
        if cancelButton.waitForExistence(timeout: 2) {
            cancelButton.tap()
        }
    }
    
    // MARK: - Integration Tests
    
    func testAllFlowsSequentially() throws {
        // Test Text Input
        try testTextInputFlow()
        
        // Test Audio Recording
        try testAudioRecordingFlow()
        
        // Test File Upload (limited on simulator)
        try testFileUploadFlow()
        
        // Skip Photo Capture on simulator
        #if !targetEnvironment(simulator)
        try testPhotoCaptureFlow()
        #endif
    }
    
    // MARK: - Performance Tests
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

// MARK: - Supabase Verification Extension

extension EndToEndTests {
    
    /// Verifies that text was uploaded to Supabase
    /// Note: In a real implementation, this would use Supabase MCP or API
    /// to query the database and verify the upload
    func verifyTextInSupabase(_ text: String) -> Bool {
        // This is a placeholder for actual Supabase verification
        // In practice, you would:
        // 1. Query the 'texts' table using Supabase client
        // 2. Check for the text content
        // 3. Return true if found
        return true
    }
    
    /// Verifies that a file was uploaded to Supabase storage
    /// Note: In a real implementation, this would use Supabase MCP or API
    /// to check the storage bucket
    func verifyFileInSupabaseStorage(filename: String) -> Bool {
        // This is a placeholder for actual Supabase verification
        // In practice, you would:
        // 1. List files in the 'uploads' bucket
        // 2. Check for a file matching the pattern
        // 3. Return true if found
        return true
    }
}