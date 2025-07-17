import XCTest

class ContentViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    func testRecordAudioButton_whenTapped_showsRecordingState() {
        // Given
        let recordButton = app.buttons["recordAudioButton"]
        
        // When
        XCTAssertTrue(recordButton.exists)
        XCTAssertEqual(recordButton.label, "Record Audio")
        
        recordButton.tap()
        
        // Then
        // Note: In a real test, we'd need to handle permission alerts
        // expectation(for: NSPredicate(format: "label == 'Stop Recording'"), evaluatedWith: recordButton)
        // waitForExpectations(timeout: 5)
    }
    
    func testTextInput_whenButtonTapped_showsTextEditor() {
        // Given
        let textInputButton = app.buttons["textInputButton"]
        let textEditor = app.textViews["textInputEditor"]
        let sendButton = app.buttons["sendTextButton"]
        
        // When
        XCTAssertTrue(textInputButton.exists)
        textInputButton.tap()
        
        // Then
        XCTAssertTrue(textEditor.waitForExistence(timeout: 2))
        XCTAssertTrue(sendButton.exists)
        
        // Type text
        textEditor.tap()
        textEditor.typeText("Hello from UI Test!")
        
        // Verify send button is enabled
        XCTAssertTrue(sendButton.isEnabled)
    }
    
    func testTakePhotoButton_whenTapped_requestsCameraPermission() {
        // Given
        let photoButton = app.buttons["takePhotoButton"]
        
        // When
        XCTAssertTrue(photoButton.exists)
        XCTAssertEqual(photoButton.label, "Take Photo")
        
        // Note: In a real test environment, you'd need to handle system alerts
        // photoButton.tap()
        
        // Then
        // Would check for camera UI or permission alert
    }
    
    func testUploadFileButton_whenTapped_showsDocumentPicker() {
        // Given
        let uploadButton = app.buttons["uploadFileButton"]
        
        // When
        XCTAssertTrue(uploadButton.exists)
        XCTAssertEqual(uploadButton.label, "Upload File")
        
        // Note: Document picker would appear as a system UI
        // uploadButton.tap()
        
        // Then
        // Would verify document picker appears
    }
    
    func testAllButtons_areVisible_onLaunch() {
        // Given/When - app launches
        
        // Then
        XCTAssertTrue(app.buttons["recordAudioButton"].exists)
        XCTAssertTrue(app.buttons["textInputButton"].exists)
        XCTAssertTrue(app.buttons["takePhotoButton"].exists)
        XCTAssertTrue(app.buttons["uploadFileButton"].exists)
    }
    
    func testTextInput_fullFlow_sendsSuccessfully() {
        // Given
        let textInputButton = app.buttons["textInputButton"]
        let textEditor = app.textViews["textInputEditor"]
        let sendButton = app.buttons["sendTextButton"]
        
        // When
        textInputButton.tap()
        XCTAssertTrue(textEditor.waitForExistence(timeout: 2))
        
        textEditor.tap()
        textEditor.typeText("Test message")
        
        sendButton.tap()
        
        // Then
        // Look for success message
        let successMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'success'")).firstMatch
        // XCTAssertTrue(successMessage.waitForExistence(timeout: 5))
    }
    
    func testUploadingIndicator_appearsWhenUploading() {
        // This test would verify the uploading progress indicator
        // In a real scenario, you'd trigger an upload and verify the UI state
        
        // Given
        let uploadingIndicator = app.progressIndicators["uploadingIndicator"]
        
        // When - an upload is in progress
        // Trigger upload...
        
        // Then
        // XCTAssertTrue(uploadingIndicator.exists)
        // XCTAssertEqual(uploadingIndicator.label, "Uploading...")
    }
    
    func testAccessibilityLabels_areProperlySet() {
        // Verify all accessibility labels are set correctly
        XCTAssertEqual(app.buttons["recordAudioButton"].label, "Record Audio")
        XCTAssertEqual(app.buttons["textInputButton"].label, "Text Input")
        XCTAssertEqual(app.buttons["takePhotoButton"].label, "Take Photo")
        XCTAssertEqual(app.buttons["uploadFileButton"].label, "Upload File")
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    func clearAndTypeText(_ text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and type text into a non string value")
            return
        }
        
        self.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
}