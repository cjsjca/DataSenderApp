# DataSenderApp Project Conventions

## Auto-Commit System
This project includes an automatic commit system (`auto_commit.sh`) that:
- **Watches for file changes** and commits after 5 seconds of inactivity
- **Pushes to GitHub** every 30 minutes
- **Starts automatically** via:
  - Shell profile (~/.zshrc) when opening new terminals
  - LaunchAgent (com.datasenderapp.autocommit) at system login
- **Prevents duplicates** by checking if already running
- **Logs output** to /tmp/datasenderapp-autocommit.log

## Claude CLI Remote Access (Subscription Authentication)
Successfully configured tmux-based authentication for Claude CLI access via SSH:
- **OAuth works through tmux**: Complete browser auth on any device
- **Persistent sessions**: Authentication survives SSH disconnects
- **No API charges**: Uses $250/month subscription, not pay-per-token
- **Access method**: Run `./claude_ssh.sh` from Termius SSH
- **Session management**: Ctrl+B,D to detach, reattach anytime

## Project Structure
- **Frontend/**: iOS SwiftUI application code
- **Backend/**: Backend services and storage management
- **Maintain separation**: Keep iOS-specific code in Frontend/, backend logic in Backend/

## Environment & Security
- **Never commit real tokens**: Always use `.env` file for sensitive credentials
- **Use .env & .gitignore**: Environment variables must be loaded from `.env` file
- **Required env vars**:
  - `SUPABASE_URL`
  - `SUPABASE_KEY`
  - `SUPABASE_ACCESS_TOKEN`
  - `SUPABASE_PROJECT_REF`
  - `GITHUB_TOKEN`

## Supabase Integration
- **Always use Supabase MCP for uploads**: All data operations should go through Supabase
- **Project reference**: `xvxyzmldrqewigrrccea`
- **Use Supabase Swift SDK**: Already integrated in the project
- **Storage buckets**: Configure for audio, photos, and files
- **Database tables**: Create migrations for text data storage

## Development Practices
- **SwiftUI for all UI**: Maintain modern SwiftUI patterns
- **Async/await**: Use modern Swift concurrency
- **Error handling**: Comprehensive error handling for all data operations
- **User feedback**: Always provide clear feedback for upload success/failure

## Testing
- **Test command**: `xcodebuild test -project DataSenderApp.xcodeproj -scheme DataSenderApp -destination 'platform=iOS Simulator,name=iPhone 15,OS=18.1'`
- **Run tests before commits**: Ensure all tests pass
- **Test coverage**: Cover all data capture and upload scenarios

## CI/CD
- **GitHub Actions**: Configured for automated testing
- **Workflow**: Tests Xcode build and Supabase integration

## Code Style
- **Swift conventions**: Follow standard Swift naming conventions
- **SwiftUI patterns**: Use @State, @Binding, @EnvironmentObject appropriately
- **Modular components**: Keep views small and focused
- **Comments**: Only when necessary for complex logic

## Git Workflow
- **Main branch**: Primary development branch
- **Feature branches**: Create branches for new features
- **Commit messages**: Clear and descriptive
- **Never commit .env**: Already in .gitignore

## Data Types Supported
- **Audio**: M4A format recordings
- **Text**: User input text
- **Photos**: Camera captures
- **Files**: Document picker selections

## Key Files
- `Frontend/DataSenderApp/ContentView.swift`: Main UI entry point
- `Backend/StorageManager.swift`: Core Supabase integration
- `Frontend/DataSenderApp/DataCaptureView.swift`: Data capture interface
- `.env.example`: Template for environment configuration