# DataSenderApp

![Swift](https://img.shields.io/badge/Swift-5.8+-orange.svg)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Description

DataSenderApp is an iOS 17+ SwiftUI application that provides a seamless interface for capturing and uploading various types of data. Users can record audio, dictate text, take photos, or pick files from their device and immediately upload them to an API endpoint or Supabase storage.

## Features

1. **Record Audio** - Uses AVAudioRecorder to capture audio and upload as multipart/form-data
2. **Text Input** - TextEditor interface for entering text, sent as JSON POST request
3. **Take Photo** - Camera UI integration for capturing photos with multipart upload
4. **Upload File** - UIDocumentPicker for selecting any file type with multipart upload

## Prerequisites

- **Xcode 15.0+** - Latest development environment
- **Swift 5.8+** - Modern Swift language features
- **Apple ID** - Required for code signing (free provisioning works)
- **Environment Variables**:
  - `SUPABASE_URL` - Your Supabase project URL
  - `SUPABASE_KEY` - Your Supabase anon/public key
- **npm** - For running MCP server (if using code runner integration)

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/cjsjca/DataSenderApp.git
   cd DataSenderApp
   ```

2. **Open in Xcode and add dependencies**
   - Open `DataSenderApp.xcodeproj` in Xcode
   - Go to File → Add Package Dependencies
   - Add required packages:
     - Supabase Swift client:
       ```
       https://github.com/supabase-community/supabase-swift.git
       ```
     - DotEnvSwift for environment management:
       ```
       https://github.com/swiftpackages/DotEnv.git
       ```

3. **Verify Info.plist permissions**
   The following usage descriptions should already be configured:
   - `NSMicrophoneUsageDescription` - Microphone access for audio recording
   - `NSCameraUsageDescription` - Camera access for photo capture
   - `NSPhotoLibraryUsageDescription` - Photo library access

4. **Set up Xcode scheme environment variables**
   - Edit your scheme (Product → Scheme → Edit Scheme)
   - Under Run → Arguments → Environment Variables, add:
     - `SUPABASE_URL`: Your project URL from Supabase dashboard
     - `SUPABASE_KEY`: Your anon/public key from Supabase dashboard

## Project Structure

```
DataSenderApp/
├── Frontend/
│   ├── DataSenderApp.swift      # App entry point and Supabase client initialization
│   └── ContentView.swift        # Main UI with four action buttons and state management
├── Backend/
│   ├── NetworkManager.swift     # Generic HTTP networking for API uploads
│   ├── StorageManager.swift     # Centralized Supabase storage and database upload logic
│   ├── SecretsManager.swift     # Environment variables and credentials management
│   ├── AudioRecorder.swift      # Audio recording helper with AVAudioRecorder
│   └── MCP/
│       └── .mcp.json           # MCP configuration for code runner
├── Tests/                      # Unit and UI tests (to be implemented)
├── .github/
│   └── workflows/              # GitHub Actions CI/CD pipelines
├── Info.plist                  # App permissions and configuration
├── .env.example                # Template for environment variables
├── .gitignore                  # Git ignore rules (includes .env)
├── LICENSE                     # MIT License
├── README.md                   # This documentation file
└── INTERPRETER_GUIDE.md        # MCP usage guide for code runners
```

## Code Runner Usage

When running Git or GitHub commands in the code runner, always use the configured github MCP server defined in Backend/MCP/.mcp.json instead of embedding usernames or passwords. Use `claude mcp list` to verify that github is active, then prefix your commands with `GITHUB>` (for example, `GITHUB> create branch my-feature`, `GITHUB> commit .` and `GITHUB> push origin main`).

For detailed MCP usage instructions, see [INTERPRETER_GUIDE.md](INTERPRETER_GUIDE.md).

## Supabase MCP Integration

The `Backend/MCP/.mcp.json` file configures a Model Context Protocol (MCP) server for Supabase, enabling the code runner to interact directly with your Supabase project.

### Supabase Configuration

**Note**: This app uses the Supabase Data API exclusively (via SUPABASE_URL and SUPABASE_KEY) and does not embed any Postgres connection string.

### Configuration

The `Backend/MCP/.mcp.json` contains:
```json
// This file configures MCP servers for code runner reuse
// After updating with your credentials, run: claude mcp list
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-supabase@latest",
        "--read-only",
        "--project-ref=<YOUR_PROJECT_REF>"
      ],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "<YOUR_PERSONAL_ACCESS_TOKEN>"
      }
    }
  }
}
```

### Setup Steps

1. Navigate to the MCP configuration:
   ```bash
   cd Backend/MCP
   ```

2. Replace placeholders in `.mcp.json`:
   - `<YOUR_PROJECT_REF>`: Found in Supabase Dashboard → Settings → General
   - `<YOUR_PERSONAL_ACCESS_TOKEN>`: Create at Account Settings → Access Tokens

3. Restart the code runner to load the MCP server:
   ```bash
   claude mcp list
   ```

### Example Code Runner Commands

```
SUPABASE> list tables in public
SUPABASE> upload file myPhoto.jpg to bucket 'uploads'
SUPABASE> query table texts limit 10
SUPABASE> describe table texts
```

## Usage

### Running the App

1. **Connect your iOS device** or use the simulator
2. **Select your device** as the run destination in Xcode
3. **Enable automatic signing**:
   - Select the project in navigator
   - Go to Signing & Capabilities
   - Check "Automatically manage signing"
   - Select your personal team (free Apple ID works)
4. **Build and run** (Cmd+R)

### Example User Flows

**Recording Audio:**
1. Tap "Record Audio"
2. Grant microphone permission (first time only)
3. Speak your message
4. Tap "Stop Recording"
5. Audio uploads automatically to Supabase storage

**Entering Text:**
1. Tap "Text Input"
2. Type your message in the text editor
3. Tap "Send"
4. Text saves to Supabase database `texts` table

**Taking a Photo:**
1. Tap "Take Photo"
2. Grant camera permission (first time only)
3. Capture your photo
4. Tap "Use Photo"
5. Image uploads to Supabase storage

**Uploading a File:**
1. Tap "Upload File"
2. Browse and select any file
3. File uploads to Supabase storage with original filename

## Testing

The project includes comprehensive unit and UI tests to ensure code quality and functionality.

### Unit Tests

Unit tests are located in `Tests/UnitTests/` and cover the core business logic:

- **NetworkManagerTests.swift** - Tests network upload functionality with mocked URLSession
- **StorageManagerTests.swift** - Tests Supabase storage operations with mocked clients
- **SecretsManagerTests.swift** - Tests environment variable loading and validation

#### Running Unit Tests

**In Xcode:**
```bash
# Run all tests
⌘U

# Run specific test class
Click on the diamond next to the test class name
```

**Via Command Line:**
```bash
# Run all unit tests
xcodebuild test \
  -scheme DataSenderApp \
  -destination "platform=iOS Simulator,name=iPhone 14" \
  -only-testing:DataSenderAppTests

# Run with specific iOS version
xcodebuild test \
  -scheme DataSenderApp \
  -destination "platform=iOS Simulator,name=iPhone 14,OS=17.0" \
  -resultBundlePath TestResults
```

### UI Tests

UI tests are located in `Tests/UITests/` and test the user interface interactions:

- **ContentViewUITests.swift** - Tests all button interactions, text input, and upload flows

#### Running UI Tests

**In Xcode:**
1. Select the `DataSenderAppUITests` scheme
2. Choose a simulator or device
3. Press ⌘U or Product → Test

**Important:** Ensure the app has the necessary permissions granted in the simulator before running UI tests.

### Accessibility Identifiers

The following accessibility identifiers are set in ContentView.swift for UI testing:

| View Element | Identifier | Description |
|--------------|------------|-------------|
| Record Audio Button | `recordAudioButton` | Main recording button |
| Text Input Button | `textInputButton` | Shows/hides text input |
| Text Editor | `textInputEditor` | Multiline text input field |
| Send Button | `sendTextButton` | Sends text to server |
| Take Photo Button | `takePhotoButton` | Opens camera |
| Upload File Button | `uploadFileButton` | Opens document picker |
| Upload Progress | `uploadingIndicator` | Shows during uploads |

### Writing New Tests

#### Unit Test Example:
```swift
func testUpload_whenValidData_returnsSuccess() async throws {
    // Given
    let testData = "Test".data(using: .utf8)!
    let mockSession = MockURLSession()
    
    // When
    let result = try await sut.upload(data: testData, filename: "test.txt", mimeType: "text/plain")
    
    // Then
    XCTAssertNotNil(result)
}
```

#### UI Test Example:
```swift
func testTextInput_whenButtonTapped_showsTextEditor() {
    // Given
    let textButton = app.buttons["textInputButton"]
    
    // When
    textButton.tap()
    
    // Then
    XCTAssertTrue(app.textViews["textInputEditor"].exists)
}
```

### Continuous Integration

To run tests in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run Tests
  run: |
    xcodebuild test \
      -scheme DataSenderApp \
      -sdk iphonesimulator \
      -destination "platform=iOS Simulator,name=iPhone 14" \
      -enableCodeCoverage YES
```

### Test Coverage

To generate test coverage reports:

```bash
# Run tests with coverage
xcodebuild test \
  -scheme DataSenderApp \
  -enableCodeCoverage YES \
  -destination "platform=iOS Simulator,name=iPhone 14"

# Generate coverage report
xcrun llvm-cov export \
  -format="lcov" \
  -instr-profile=path/to/Coverage.profdata \
  path/to/DataSenderApp.app/DataSenderApp \
  > coverage.lcov
```

## Reusability Tip

To quickly add Supabase integration to a new SwiftUI project:

1. **Copy `Backend/MCP/.mcp.json`** to your new project
2. **Copy this README's Supabase MCP Integration section** for reference
3. **Update the placeholders** with your new project's credentials
4. **Run `claude mcp list`** to activate

This gives you instant code runner access to your Supabase resources!

## Secrets Management

The app uses a centralized `SecretsManager` class (located in `Backend/SecretsManager.swift`) to handle all environment variables and API credentials securely.

### Setup Instructions

1. **Copy the example environment file**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` with your actual credentials**
   ```bash
   # Open in your preferred editor
   nano .env
   # or
   code .env
   ```

3. **Fill in all required values**
   - Replace all placeholder values with your actual API keys and credentials
   - Ensure no quotes around values unless they contain spaces
   - Comment out any services you're not using

4. **Add `.env` to your Xcode project** (if running locally)
   - Drag `.env` file into Xcode project navigator
   - Select "Copy items if needed"
   - Add to your app target

5. **Rebuild the app**
   - Clean build folder (Cmd+Shift+K)
   - Build and run (Cmd+R)

### Available Secrets

The `Backend/SecretsManager.swift` provides static properties for:
- **Supabase**: `supabaseUrl`, `supabaseKey`, `supabaseProjectRef`, `supabaseAccessToken`
- **OpenAI**: `openAIApiKey`, `openAIOrgId`
- **AWS**: `awsAccessKeyId`, `awsSecretAccessKey`, `awsRegion`, `awsS3Bucket`
- **Google Cloud**: `googleCloudProjectId`, `googleCloudApiKey`
- **Firebase**: `firebaseApiKey`, `firebaseProjectId`, `firebaseAuthDomain`
- **Stripe**: `stripePublishableKey`, `stripeSecretKey`
- **Twilio**: `twilioAccountSid`, `twilioAuthToken`, `twilioPhoneNumber`
- **SendGrid**: `sendGridApiKey`
- **Slack**: `slackBotToken`, `slackSigningSecret`
- **GitHub**: `githubAccessToken`, `githubToken`
- **Custom API**: `apiBaseUrl`, `apiKey`
- **App Config**: `environment`, `debugMode`

### Usage Example

```swift
// In your app code
let supabaseClient = SupabaseClient(
    supabaseURL: URL(string: SecretsManager.supabaseUrl)!,
    supabaseKey: SecretsManager.supabaseKey
)

// For optional values
if let orgId = SecretsManager.openAIOrgId {
    // Use organization ID
}
```

### Security Notes

- **Never commit `.env` files** - Already excluded in `.gitignore`
- **Use different credentials** for development and production
- **Rotate secrets regularly** and update your `.env` file
- **For production**, use Xcode's environment variables or a secure CI/CD pipeline

## GitHub MCP Integration

The `Backend/MCP/.mcp.json` file includes GitHub MCP server configuration, enabling the code runner to interact with your GitHub repository directly.

### Setup Instructions

1. **Add GitHub token to your environment**
   ```bash
   # Copy the example file if you haven't already
   cp .env.example .env
   
   # Edit .env and add your GitHub token
   # GITHUB_TOKEN=ghp_your-github-token-here
   ```

2. **Update GitHub configuration in `.mcp.json`**
   - Navigate to `Backend/MCP/.mcp.json`
   - Replace `your-username` with your GitHub username
   - Replace `<YOUR_GITHUB_TOKEN>` with your actual token (or keep placeholder if using .env)

3. **Restart the code runner**
   ```bash
   claude mcp list
   ```

### Example Code Runner Commands

```
# Branch operations
GITHUB> create branch feature/add-github-mcp
GITHUB> list branches
GITHUB> checkout main

# Commit operations
GITHUB> commit Backend/SecretsManager.swift "Add GitHub MCP token support"
GITHUB> commit Frontend/ContentView.swift "Update UI for new feature"

# Push and pull
GITHUB> push origin feature/add-github-mcp
GITHUB> pull origin main

# Issue and PR operations
GITHUB> create issue "Add GitHub MCP integration" "Need to integrate GitHub MCP server"
GITHUB> list issues
GITHUB> create pr "Add GitHub MCP support" "This PR adds GitHub MCP server configuration"

# Repository information
GITHUB> list files
GITHUB> show README.md
GITHUB> search "SecretsManager"
```

### GitHub Token Permissions

Your GitHub token should have the following scopes:
- `repo` - Full control of private repositories
- `workflow` - Update GitHub Action workflows
- `read:org` - Read org and team membership (if applicable)

### Tips

- Use fine-grained personal access tokens for better security
- Store different tokens for different purposes (one for MCP, one for API access)
- The GitHub MCP server provides direct repository access without leaving the code runner

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Reporting Issues

Please use the [GitHub Issues](https://github.com/cjsjca/DataSenderApp/issues) page to report bugs or request features.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.