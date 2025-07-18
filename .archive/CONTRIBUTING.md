# Contributing to DataSenderApp

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Style Guidelines](#style-guidelines)
- [Testing](#testing)
- [Using the Code Runner](#using-the-code-runner)
- [Pull Request Process](#pull-request-process)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by the [DataSenderApp Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Started

### Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.8 or later
- Homebrew (for dependency management)
- npm (for MCP servers)

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/cjsjca/DataSenderApp.git
   cd DataSenderApp
   ```

2. **Install development tools**
   ```bash
   # Install Homebrew dependencies
   brew bundle
   
   # Install Swift tools via Mint
   mint bootstrap
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   ```

4. **Configure MCP servers**
   ```bash
   cp Backend/MCP/.mcp.json.example Backend/MCP/.mcp.json
   # Edit with your tokens
   claude mcp list  # Verify setup
   ```

5. **Open in Xcode**
   ```bash
   open DataSenderApp.xcworkspace
   ```
   Or if no workspace exists yet:
   ```bash
   open DataSenderApp.xcodeproj
   ```

## How to Contribute

### Reporting Bugs

1. **Check existing issues** - Ensure the bug hasn't been reported already
2. **Create a detailed report** including:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable
   - Environment details (iOS version, device, etc.)

### Suggesting Enhancements

1. **Check the roadmap** - See if it's already planned
2. **Create an enhancement request** with:
   - Clear use case
   - Proposed solution
   - Alternative solutions considered
   - Mockups/wireframes if applicable

### Code Contributions

1. **Find an issue** - Look for issues labeled `good first issue` or `help wanted`
2. **Comment on the issue** - Let others know you're working on it
3. **Fork the repository**
4. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
5. **Make your changes** - Follow our style guidelines
6. **Add tests** - Ensure your changes are tested
7. **Commit your changes** - Use meaningful commit messages
8. **Push to your fork**
9. **Open a Pull Request**

## Style Guidelines

### Swift Code Style

We use SwiftLint and SwiftFormat to maintain consistent code style:

```bash
# Run linting
swiftlint

# Auto-format code
swiftformat .
```

Key conventions:
- 4 spaces for indentation
- No trailing whitespace
- Maximum line length of 120 characters
- Use descriptive variable names
- Add documentation comments for public APIs

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
type(scope): subject

body

footer
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Example:
```
feat(upload): add progress indicator for file uploads

- Add ProgressView during upload operations
- Show percentage complete for large files
- Display error messages on failure

Closes #123
```

## Testing

### Running Tests

**Unit Tests:**
```bash
# In Xcode
⌘U

# Command line
xcodebuild test -scheme DataSenderApp -destination "platform=iOS Simulator,name=iPhone 14"
```

**UI Tests:**
```bash
# Make sure simulator is running
xcodebuild test -scheme DataSenderAppUITests -destination "platform=iOS Simulator,name=iPhone 14"
```

### Writing Tests

- Write tests for all new features
- Maintain test coverage above 80%
- Use descriptive test names: `test_functionName_whenCondition_shouldExpectedBehavior`
- Mock external dependencies
- Test edge cases and error conditions

## Using the Code Runner

This project uses MCP (Model Context Protocol) servers for GitHub operations:

### Setup

1. Ensure your GitHub token is configured:
   ```bash
   # Check MCP servers
   claude mcp list
   ```

2. Use code runner commands instead of direct git commands:
   ```
   GITHUB> create branch feature/my-feature
   GITHUB> commit . -m "feat: add new feature"
   GITHUB> push origin feature/my-feature
   ```


## Pull Request Process

1. **Ensure all tests pass**
2. **Update documentation** if needed
3. **Add an entry to CHANGELOG.md** if applicable
4. **Request reviews** from maintainers
5. **Address review feedback**
6. **Squash commits** if requested
7. **Ensure CI passes**

### PR Title Format

Use the same format as commit messages:
```
feat(scope): brief description
```

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] UI tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

## Development Tools

### Required Tools

Install via Homebrew:
```bash
brew bundle
```

Install via Mint:
```bash
mint bootstrap
```

### Recommended Tools

- **SwiftLint** - Code linting
- **SwiftFormat** - Code formatting
- **XcodeGen** - Project generation (optional)
- **Fastlane** - Automation (optional)

## Project Structure

```
DataSenderApp/
├── Frontend/          # UI layer
├── Backend/           # Business logic
│   └── MCP/          # Code runner configs
├── Tests/            # Test suites
├── Configurations/   # Build configurations
├── Assets.xcassets/  # Images and colors
└── .github/          # CI/CD workflows
```

## Debugging

### Common Issues

**MCP Server Not Working:**
```bash
# Restart code runner
claude mcp list

# Check token validity
echo $GITHUB_TOKEN
```

**Build Errors:**
```bash
# Clean build
rm -rf ~/Library/Developer/Xcode/DerivedData
```

**Test Failures:**
```bash
# Run specific test
xcodebuild test -only-testing:DataSenderAppTests/NetworkManagerTests
```

## Community

- **GitHub Discussions** - Ask questions and share ideas
- **Issues** - Report bugs and request features
- **Pull Requests** - Contribute code
- **Wiki** - Find detailed documentation

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Annual contributor spotlight