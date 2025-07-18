const express = require('express');
const path = require('path');
// Node 18+ has fetch built-in. For older versions, use: const fetch = require('node-fetch');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// MCP endpoint configuration - change this to use different endpoints
const MCP_ENDPOINT = process.env.MCP_ENDPOINT || 'design-server';
const MCP_SERVER_URL = 'http://127.0.0.1:9090';

// Middleware setup - MUST be before routes
app.use(express.json()); // Parse JSON request bodies
app.use(express.static(path.join(__dirname, 'public'))); // Serve static files

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Function to call Claude via MCP HTTP JSON-RPC
async function callClaudeMCP(prompt) {
  console.log(`Calling MCP server with prompt: "${prompt}"`);
  
  const response = await fetch(MCP_SERVER_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      jsonrpc: '2.0',
      id: Date.now().toString(),
      method: 'chat.completions.create',
      params: {
        model: 'claude-2',
        messages: [{ role: 'user', content: prompt }],
        endpoint: MCP_ENDPOINT
      }
    })
  });
  
  const data = await response.json();
  console.log('MCP server response:', JSON.stringify(data, null, 2));
  
  if (data.error) {
    // Check for overloaded error
    if (data.error.message && data.error.message.toLowerCase().includes('overloaded')) {
      throw new Error('OVERLOADED');
    }
    throw new Error(data.error.message || JSON.stringify(data.error));
  }
  
  // Extract completion from various possible response formats
  if (data.result?.choices?.[0]?.message?.content) {
    return data.result.choices[0].message.content;
  } else if (data.result?.completion) {
    return data.result.completion;
  } else if (data.result?.content) {
    return data.result.content;
  } else if (typeof data.result === 'string') {
    return data.result;
  }
  
  throw new Error('Unexpected response format from MCP server');
}

// Function to call Claude with retry logic
async function callClaudeWithRetry(promptText, maxRetries = 3) {
  const delays = [1000, 2000, 4000]; // Exponential backoff delays in ms
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      // Wait before retry (skip on first attempt)
      if (attempt > 0) {
        const delay = delays[attempt - 1];
        console.log(`Retrying after ${delay}ms (attempt ${attempt + 1}/${maxRetries + 1})...`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
      
      console.log(`Attempt ${attempt + 1} of ${maxRetries + 1}`);
      const completion = await callClaudeMCP(promptText);
      return completion;
      
    } catch (error) {
      console.error(`Attempt ${attempt + 1} failed:`, error.message);
      
      // Check if it's an overloaded error
      if (error.message === 'OVERLOADED' || 
          (error.message && error.message.toLowerCase().includes('overloaded'))) {
        console.log('MCP server overloaded, will retry...');
        // Continue to next retry unless we're out of attempts
        if (attempt === maxRetries) {
          throw new Error('SERVICE_OVERLOADED');
        }
      } else if (attempt === maxRetries) {
        // Out of retries for other errors
        throw error;
      }
      // Continue to next attempt
    }
  }
}

// Main Claude API endpoint
app.post('/api/claude', async (req, res) => {
  console.log('Received request:', req.body);
  const { text } = req.body;
  
  // Validate input
  if (!text || typeof text !== 'string') {
    return res.status(400).json({ error: 'Missing or invalid text field' });
  }
  
  try {
    // Call Claude with retry logic
    const completion = await callClaudeWithRetry(text);
    
    console.log('Successfully got completion from MCP server');
    
    // Send response
    res.json({ completion });
    
  } catch (error) {
    console.error('Error calling Claude:', error);
    
    // Handle specific error types
    if (error.message === 'SERVICE_OVERLOADED') {
      // Service overloaded after all retries
      res.status(503).json({ 
        error: 'Service overloaded, please try again later' 
      });
    } else {
      // Other errors
      res.status(500).json({ 
        error: error.message || 'Failed to get response from Claude' 
      });
    }
  }
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// Start the server
app.listen(PORT, '127.0.0.1', () => {
  console.log(`\n🚀 Claude Web Interface with MCP Support`);
  console.log(`📍 Running at: http://localhost:${PORT}`);
  console.log(`🔧 Health check: http://localhost:${PORT}/health`);
  console.log(`\n📡 Using MCP server at: ${MCP_SERVER_URL}`);
  console.log(`📡 Using MCP endpoint: ${MCP_ENDPOINT}`);
  console.log(`✅ Using HTTP JSON-RPC to communicate with MCP server`);
  console.log(`\n⚠️  Make sure MCP server is running:`);
  console.log(`    claude mcp serve --transport http --port 9090 --dangerously-skip-permissions`);
  console.log(`\n⚠️  Make sure endpoints are registered:`);
  console.log(`    claude mcp add --transport http design-server http://127.0.0.1:9090`);
  console.log(`    claude mcp add --transport http exec-server http://127.0.0.1:9090\n`);
});