#!/usr/bin/env node
/**
 * MCP Chat Server - Bridge between web interface and Claude CLI
 * This MCP server accepts HTTP requests and exposes them as tools to Claude
 */

import express from 'express';
import cors from 'cors';
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

// Message queue
const messageQueue = [];
let lastMessageId = 0;

// Create HTTP server for receiving messages
const app = express();
app.use(cors());
app.use(express.json());

// Receive messages from web interface
app.post('/send', (req, res) => {
  const { message } = req.body;
  if (message) {
    lastMessageId++;
    messageQueue.push({
      id: lastMessageId,
      message,
      timestamp: new Date().toISOString(),
      read: false
    });
    res.json({ success: true, id: lastMessageId });
  } else {
    res.status(400).json({ error: 'No message provided' });
  }
});

// Start HTTP server on port 3000
app.listen(3000, () => {
  console.error('HTTP server listening on port 3000');
});

// Create MCP server
const server = new Server(
  {
    name: 'chat-bridge',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Handle tool listing
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'get_messages',
        description: 'Get unread messages from the web interface',
        inputSchema: {
          type: 'object',
          properties: {
            mark_as_read: {
              type: 'boolean',
              description: 'Mark messages as read after retrieving',
              default: true
            }
          }
        },
      },
      {
        name: 'send_response',
        description: 'Send a response back to the web interface',
        inputSchema: {
          type: 'object',
          properties: {
            message: {
              type: 'string',
              description: 'Response message to send'
            }
          },
          required: ['message']
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case 'get_messages': {
      const unread = messageQueue.filter(m => !m.read);
      
      if (args.mark_as_read) {
        unread.forEach(m => m.read = true);
      }
      
      return {
        content: [
          {
            type: 'text',
            text: unread.length > 0 
              ? `Found ${unread.length} new messages:\n${unread.map(m => `[${m.timestamp}] ${m.message}`).join('\n')}`
              : 'No new messages'
          }
        ]
      };
    }

    case 'send_response': {
      // In a real implementation, this would send to web interface
      // For now, just acknowledge
      return {
        content: [
          {
            type: 'text',
            text: `Response queued: "${args.message}"`
          }
        ]
      };
    }

    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

// Start MCP server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('MCP Chat Bridge Server running');
}

main().catch(console.error);