# DataSenderApp

![Swift](https://img.shields.io/badge/Swift-5.8+-orange.svg)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
[![CI](https://github.com/cjsjca/DataSenderApp/actions/workflows/ci.yml/badge.svg)](https://github.com/cjsjca/DataSenderApp/actions/workflows/ci.yml)

## Description

DataSenderApp is a pure SwiftUI iOS application that provides a seamless interface for capturing and uploading various types of data to Supabase. Built entirely with SwiftUI (no UIKit wrappers), users can record audio, input text, select photos, or choose files from their device and immediately upload them to Supabase storage.

## Features

- **🎙️ Audio Recording** - Pure SwiftUI controls driving AVAudioRecorder for audio capture and upload
- **📝 Text Input** - Native SwiftUI TextEditor with JSON POST to Supabase
- **📷 Photo Selection** - SwiftUI PhotosPicker for selecting images from the photo library
- **📁 File Upload** - SwiftUI's native fileImporter for selecting and uploading any file type
- **☁️ Supabase Integration** - All data is securely stored in Supabase with proper authentication
- **🔐 Secure Credentials** - Environment-based configuration for API keys and tokens

## Prerequisites

- **Xcode 15.0+** - Latest development environment
- **iOS 17.0+** - Minimum deployment target
- **Swift 5.8+** - Modern Swift language features
- **Supabase Account** - For backend storage and database
- **GitHub Account** - For version control and CI/CD

## Code-First Project Setup

1. **Install XcodeGen** with `brew install xcodegen`

2. **Ensure project.yml exists** at the repo root defining the DataSenderApp and test bundle targets (Debug/Release with `ENABLE_TESTABILITY = YES` in Debug, sources under `Frontend/`, `Backend/`, and test sources under `Tests/UnitTests` and `Tests/UITests`)

3. **Generate the Xcode project** by running `xcodegen generate`

4. **Build the app** via shell MCP using:
   ```bash
   claude mcp run shell -- xcodebuild build -project DataSenderApp.xcodeproj -scheme DataSenderApp -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5"
   ```

5. **Run tests** via shell MCP using:
   ```bash
   claude mcp run shell -- xcodebuild test -project DataSenderApp.xcodeproj -scheme DataSenderApp -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5"
   ```

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/cjsjca/DataSenderApp.git
   cd DataSenderApp
   ```

2. **Set up Supabase credentials**
   ```bash
   cp Config/Secrets.xcconfig.example Config/Secrets.xcconfig
   # Edit Secrets.xcconfig with your actual Supabase URL and key
   ```

3. **Generate the Xcode project**
   ```bash
   xcodegen generate
   ```

4. **Dependencies**
   - Swift Package Manager dependencies are defined in `project.yml`:
     - [Supabase Swift](https://github.com/supabase-community/supabase-swift)

5. **Build and run**
   - Use the xcodebuild commands from the Code-First Project Setup section
   - Or open the generated project: `open DataSenderApp.xcodeproj`

## Project Structure

```
DataSenderApp/
├── Frontend/                 # UI Layer (Pure SwiftUI)
│   ├── ContentView.swift    # Main UI with pure SwiftUI components
│   └── DataSenderApp.swift  # App entry point
├── Backend/                 # Business Logic
│   ├── AudioRecorder.swift  # Audio recording functionality
│   ├── NetworkManager.swift # Generic networking (legacy)
│   ├── StorageManager.swift # Supabase storage operations
│   ├── SecretsManager.swift # Environment variable management
│   └── MCP/                # Model Context Protocol config
│       ├── .mcp.json       # MCP server configuration
│       └── .mcp.json.example
├── Tests/                   # Test Suites
│   ├── UnitTests/          # Unit tests for managers
│   └── UITests/            # UI automation tests
├── Configurations/          # Build Configurations
│   ├── Base.xcconfig
│   ├── Debug.xcconfig
│   └── Release.xcconfig
├── .github/                 # GitHub Actions
│   └── workflows/
│       └── ci.yml          # CI/CD pipeline
├── DataSenderApp.xcodeproj  # Xcode project
├── Package.swift            # SPM manifest
├── .env.example            # Environment template
└── README.md               # This file
```

## Usage

### Text Input
The app allows users to input multiline text through a TextEditor and store it in Supabase. The data is sent as JSON to the `texts` table:

**JSON Schema:**
```json
{
  "content": "<user input>"
}
```

**Example Usage:**
1. Tap the "Text Input" button
2. Type or paste text in the TextEditor
3. Tap "Send" to upload to Supabase
4. The text is stored in the `texts` table with the schema above

### Photo Selection
The app uses SwiftUI's native PhotosPicker for selecting and uploading photos:

**Flow:**
1. Tap the "Select Photo" button
2. The native iOS photo picker appears
3. Select a photo from your library
4. The photo is automatically converted to JPEG format (80% quality)
5. Uploaded to the "uploads" bucket in Supabase storage
6. Success/error alert displays the result
7. File is stored with a unique UUID-based filename

**Storage Format:**
- Bucket: `uploads`
- Filename: `photo-{UUID}.jpg`
- MIME type: `image/jpeg`

### File Upload
The app uses SwiftUI's native fileImporter to allow users to select and upload any file type:

**Flow:**
1. Tap the "Upload File" button
2. A file picker appears (on simulator, this shows the Mac file browser)
3. Select any file type from your file system
4. The file is automatically uploaded to Supabase storage
5. Success/error alert displays the result
6. Files are stored with their original filenames

**Storage Format:**
- Bucket: `uploads`
- Filename: Original filename with UUID prefix for uniqueness
- MIME type: Automatically detected based on file extension

**Simulator Note:** When running in the iOS Simulator, the fileImporter displays the Mac's native file browser, allowing easy testing with files from your Mac's file system.

### Audio Recording
The app provides audio recording functionality with a pure SwiftUI interface:

**Flow:**
1. Tap the "Record Audio" button (turns red when recording)
2. Grant microphone permissions when prompted
3. The app begins recording using AVAudioRecorder under the hood
4. Tap "Stop Recording" to end the recording
5. Audio is automatically uploaded as M4A format to Supabase storage
6. Success/error alert displays the result

**Storage Format:**
- Bucket: `uploads`
- Filename: `audio-{UUID}.m4a`
- MIME type: `audio/m4a`

**Architecture Note:** While the UI is pure SwiftUI, AVAudioRecorder is used under the hood for actual audio capture, as SwiftUI doesn't yet provide native audio recording APIs.

## Supabase MCP Integration

This project includes Model Context Protocol (MCP) integration for Supabase operations.

### Configuration

1. **Update MCP credentials**
   ```bash
   # Copy the example configuration
   cp Backend/MCP/.mcp.json.example Backend/MCP/.mcp.json
   
   # Edit with your credentials
   # Add your SUPABASE_ACCESS_TOKEN and project-ref
   ```

2. **Verify MCP setup**
   ```bash
   claude mcp list
   ```

### Available MCP Commands

When using Claude Code CLI, you can interact with Supabase directly:

- List tables: `SUPABASE> list tables`
- Query data: `SUPABASE> select * from texts`
- View storage: `SUPABASE> list buckets`

## Code Runner Usage

This project is optimized for use with Claude Code CLI. The MCP configuration enables direct interaction with both Supabase and GitHub.

### GitHub Operations

```bash
# Create a branch
GITHUB> create branch feature/new-feature

# Commit changes
GITHUB> commit -am "Add new feature"

# Push to remote
GITHUB> push origin feature/new-feature

# Create pull request
GITHUB> create pr "New Feature" "Description of changes"
```

### Supabase Operations

```bash
# Check storage buckets
SUPABASE> storage list-buckets

# Query uploaded texts
SUPABASE> from texts select *

# View recent uploads
SUPABASE> from storage.objects select * order by created_at desc limit 10
```

### Persistent Memory

Claude Code CLI supports persistent memory through `CLAUDE.md` files, which store project-specific conventions and knowledge across sessions.

1. **Bootstrap memory** by running `/init` at the project root to generate `CLAUDE.md`:
   ```bash
   cd /path/to/DataSenderApp
   claude /init
   ```
   This analyzes your project structure and creates a foundational memory file.

2. **Add new facts** with `/memory add <your note>`:
   ```bash
   claude /memory add "Always run tests before committing with: xcodebuild test -scheme DataSenderApp"
   claude /memory add "Storage buckets: 'audio', 'photos', 'files' for respective data types"
   ```

3. **Review memory** with `/memory list`:
   ```bash
   claude /memory list
   ```
   This displays all stored facts and conventions from `CLAUDE.md`.

4. **Refresh chat context** with `/clear` without losing stored memory:
   ```bash
   claude /clear
   ```
   This clears the conversation history but preserves all facts in `CLAUDE.md`.

**💡 Pro Tip**: Create a shell alias for quick memory initialization:

```bash
# Add to ~/.zshrc (for Zsh) or ~/.bash_profile (for Bash)
alias claude-init="claude /init"

# Then simply run after cd'ing into any project:
cd /path/to/DataSenderApp
claude-init
```

This way, you can quickly bootstrap Claude's memory for any project, ensuring it understands your project conventions, test commands, and specific requirements from the start of each session.

### Troubleshooting: Project Path Changes

1. **Launch Claude Code in the correct directory:**
   ```bash
   cd ~/Projects/DataSenderApp
   claude
   ```

2. **Re-open the Xcode project:**
   ```bash
   open ~/Projects/DataSenderApp/DataSenderApp.xcodeproj
   ```

3. **Refresh persistent memory:**
   ```bash
   /clear
   /init
   ```

4. **Re-register MCP servers if needed** using your one-block registration prompts from the Persistent Memory guide.

5. **Update any hard-coded paths** by searching scripts, README, and CI configs for old `~/Documents/...` references and replacing them with `~/Projects/DataSenderApp/...` or using relative paths.

6. **Re-build and re-run tests with:**
   ```bash
   claude mcp run shell -- xcodebuild build -project DataSenderApp.xcodeproj -scheme DataSenderApp -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5"
   claude mcp run shell -- xcodebuild test -project DataSenderApp.xcodeproj -scheme DataSenderApp -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5"
   ```

## Testing

### Run Unit Tests

```bash
# Using xcodebuild
xcodebuild test -scheme DataSenderApp -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5'
```

### Run UI Tests

```bash
# Run UI tests
xcodebuild test -scheme DataSenderApp -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' -only-testing:DataSenderAppUITests
```

### Test Coverage

- Unit tests cover all manager classes
- UI tests verify all user interactions
- Accessibility identifiers enable reliable UI testing

## Secrets Setup

1. **Create `Secrets.xcconfig` file**
   ```bash
   cp Config/Secrets.xcconfig.example Config/Secrets.xcconfig
   ```

2. **Add your Supabase credentials**
   ```xcconfig
   // Supabase Configuration
   SUPABASE_URL = https://your-project.supabase.co
   SUPABASE_KEY = your-anon-public-key
   ```

3. **Never commit `Secrets.xcconfig` file**
   - Already included in `.gitignore`
   - Credentials are baked into the build via Info.plist
   - For CI/CD, use environment variables for optional tokens

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint for code consistency
- Add tests for new features
- Update documentation as needed

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Supabase](https://supabase.com) for the backend infrastructure
- [Claude Code CLI](https://github.com/anthropics/claude-code) for AI-assisted development
- [Swift Package Manager](https://swift.org/package-manager/) for dependency management

## Support

For issues and feature requests, please use the [GitHub Issues](https://github.com/cjsjca/DataSenderApp/issues) page.