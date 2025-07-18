# Claude Twins - Multiple Claude Instances

This folder contains configurations for running multiple Claude instances that communicate via MCP.

## Why This Organization?

- **Conceptual clarity**: These are twin Claude instances, not separate apps
- **Part of the system**: They're components of the DataSenderApp agent system
- **Testing ground**: For MCP communication experiments

## Structure Options

### Option 1: Named Instances
```
claude_twins/
├── alice/
│   └── .mcp.json
├── bob/
│   └── .mcp.json
└── README.md
```

### Option 2: Numbered Instances  
```
claude_twins/
├── instance_1/
│   └── .mcp.json
├── instance_2/
│   └── .mcp.json
└── README.md
```

### Option 3: Role-Based
```
claude_twins/
├── coordinator/
│   └── .mcp.json
├── worker/
│   └── .mcp.json
└── README.md
```

## Current Approach

For now, let's keep it simple with instance_1 and instance_2, but the folder structure makes it clear these are:
- Twin Claude processes
- Part of the same system
- Communicating through MCP
- Not separate applications