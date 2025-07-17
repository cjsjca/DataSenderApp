# DataSenderApp

![Swift](https://img.shields.io/badge/Swift-5.8+-orange.svg)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
[![CI](https://github.com/cjsjca/DataSenderApp/actions/workflows/ci.yml/badge.svg)](https://github.com/cjsjca/DataSenderApp/actions/workflows/ci.yml)

## Description

DataSenderApp is a SwiftUI iOS application that provides a seamless interface for capturing and uploading various types of data to Supabase. Users can record audio, input text, take photos, or select files from their device and immediately upload them to Supabase storage.

## Features

- **🎙️ Audio Recording** - Record audio using AVAudioRecorder and upload to Supabase storage
- **📝 Text Input** - Enter text with a SwiftUI TextEditor and store in Supabase database
- **📷 Photo Capture** - Take photos using the camera and upload to Supabase storage
- **📁 File Upload** - Select any file type using UIDocumentPicker and upload to Supabase
- **☁️ Supabase Integration** - All data is securely stored in Supabase with proper authentication
- **🔐 Secure Credentials** - Environment-based configuration for API keys and tokens

## Prerequisites

- **Xcode 15.0+** - Latest development environment
- **iOS 17.0+** - Minimum deployment target
- **Swift 5.8+** - Modern Swift language features
- **Supabase Account** - For backend storage and database
- **GitHub Account** - For version control and CI/CD

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/cjsjca/DataSenderApp.git
   cd DataSenderApp
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your actual credentials
   ```

3. **Open in Xcode**
   ```bash
   open DataSenderApp.xcodeproj
   ```

4. **Install dependencies**
   - Xcode will automatically resolve Swift Package Manager dependencies
   - Main dependencies:
     - [Supabase Swift](https://github.com/supabase-community/supabase-swift)
     - [DotEnvSwift](https://github.com/swiftpackages/DotEnv)

5. **Run the app**
   - Select your target device/simulator
   - Press ⌘R or click the Run button

## Project Structure

```
DataSenderApp/
├── Frontend/                 # UI Layer
│   ├── ContentView.swift    # Main UI with four action buttons
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

## Testing

### Run Unit Tests

```bash
# Using Xcode
xcodebuild test -scheme DataSenderApp -destination 'platform=iOS Simulator,name=iPhone 15'

# Or in Xcode IDE
⌘U
```

### Run UI Tests

```bash
# Ensure simulator is running
xcodebuild test -scheme DataSenderAppUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Test Coverage

- Unit tests cover all manager classes
- UI tests verify all user interactions
- Accessibility identifiers enable reliable UI testing

## Secrets Setup

1. **Create `.env` file**
   ```bash
   cp .env.example .env
   ```

2. **Add your credentials**
   ```env
   # Supabase Configuration
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_KEY=your-anon-public-key
   SUPABASE_ACCESS_TOKEN=your-personal-access-token
   SUPABASE_PROJECT_REF=your-project-ref
   
   # GitHub Configuration
   GITHUB_TOKEN=your-github-personal-access-token
   ```

3. **Never commit `.env` file**
   - Already included in `.gitignore`
   - Use environment variables in CI/CD

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