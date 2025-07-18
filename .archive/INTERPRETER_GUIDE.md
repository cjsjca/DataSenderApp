# Code Interpreter (Claude Code) Usage Guide

When running Git or GitHub commands inside Claude Code CLI, always use the configured github MCP server defined in Backend/MCP/.mcp.json instead of embedding usernames or passwords. Use `claude mcp list` to verify that github is active, then prefix your commands with `GITHUB>` (for example, `GITHUB> create branch my-feature`, `GITHUB> commit .` and `GITHUB> push origin main`).

## MCP Server Configuration

The GitHub MCP server is configured in `Backend/MCP/.mcp.json` and provides secure access to GitHub operations without exposing credentials in commands.

## Verifying MCP Server Status

Before using GitHub commands, verify the MCP server is active:

```bash
claude mcp list
```

You should see `github` in the list of active MCP servers.

## Common GitHub MCP Commands

### Branch Operations
```
GITHUB> create branch feature/new-feature
GITHUB> list branches
GITHUB> checkout main
GITHUB> delete branch feature/old-feature
```

### Commit Operations
```
GITHUB> status
GITHUB> add .
GITHUB> commit . -m "Your commit message"
GITHUB> commit Backend/file.swift -m "Update specific file"
```

### Push and Pull
```
GITHUB> push origin main
GITHUB> push origin feature/new-feature
GITHUB> pull origin main
```

### Repository Information
```
GITHUB> list files
GITHUB> show README.md
GITHUB> search "keyword"
```

### Issues and Pull Requests
```
GITHUB> create issue "Issue title" "Issue description"
GITHUB> list issues
GITHUB> create pr "PR title" "PR description"
GITHUB> list prs
```

## Important Notes

1. **Never use git commands with embedded credentials** - Always use the MCP server
2. **The MCP server uses the token** configured in `Backend/MCP/.mcp.json`
3. **All operations are performed** on the repository specified in the MCP configuration
4. **If you get authentication errors**, check that your GitHub token in `.mcp.json` is valid

## Troubleshooting

If MCP commands aren't working:

1. Check that `claude mcp list` shows the github server
2. Verify your token hasn't expired
3. Ensure the repository name and owner are correct in `.mcp.json`
4. Restart Claude Code after making configuration changes

## Security Best Practices

1. Never commit `.mcp.json` with real tokens
2. Use `.mcp.json.example` as a template for others
3. Keep your GitHub token permissions minimal
4. Rotate tokens regularly