const express = require('express');
const { spawn } = require('child_process');
const path = require('path');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// MCP endpoint configuration - change this to use different endpoints
const MCP_ENDPOINT = 'design-server'; // or 'exec-server' for execution tasks

// Middleware setup - MUST be before routes
app.use(express.json()); // Parse JSON request bodies
app.use(express.static(path.join(__dirname, 'public'))); // Serve static files

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Function to call Claude via MCP
async function callClaudeMCP(promptText) {
  return new Promise((resolve, reject) => {
    console.log(`Calling Claude MCP with prompt: "${promptText}"`);
    
    // Spawn Claude MCP call command
    const claude = spawn('/opt/homebrew/bin/claude', [
      'mcp',
      'call',
      MCP_ENDPOINT,
      '-p',
      promptText,
      '--output-format',
      'json'
    ], {
      env: process.env, // Inherit all environment variables
      stdio: ['pipe', 'pipe', 'pipe'] // Pipe stdin, stdout, stderr
    });
    
    let stdoutBuffer = '';
    let stderrBuffer = '';
    let hasResolved = false;
    
    // Handle stdout data
    claude.stdout.on('data', (chunk) => {
      stdoutBuffer += chunk.toString();
      console.log('MCP stdout chunk:', chunk.toString());
    });
    
    // Handle stderr data
    claude.stderr.on('data', (chunk) => {
      const data = chunk.toString();
      stderrBuffer += data;
      console.error('MCP stderr:', data);
    });
    
    // Handle process exit
    claude.on('close', (code) => {
      if (!hasResolved) {
        console.log(`MCP process exited with code: ${code}`);
        
        if (code === 0 && stdoutBuffer) {
          // Try to parse JSON response
          try {
            const trimmed = stdoutBuffer.trim();
            const parsed = JSON.parse(trimmed);
            console.log('Successfully parsed MCP JSON response');
            
            // Extract completion from various possible fields
            const completion = parsed.result || 
                             parsed.completion || 
                             parsed.content || 
                             parsed.output || 
                             parsed.response ||
                             '';
            
            hasResolved = true;
            resolve(completion);
          } catch (e) {
            console.error('Failed to parse JSON:', e);
            reject(new Error('Invalid JSON response from Claude MCP'));
          }
        } else if (stderrBuffer.toLowerCase().includes('overloaded')) {
          reject(new Error('OVERLOADED'));
        } else {
          reject(new Error(`Claude MCP exited with code ${code}: ${stderrBuffer || 'No error output'}`));
        }
      }
    });
    
    // Handle process errors
    claude.on('error', (error) => {
      console.error('MCP spawn error:', error);
      if (!hasResolved) {
        hasResolved = true;
        reject(new Error(`Failed to spawn Claude MCP: ${error.message}`));
      }
    });
    
    // Set a timeout to prevent hanging forever
    setTimeout(() => {
      if (!hasResolved) {
        console.log('Timeout reached, killing MCP process');
        hasResolved = true;
        claude.kill('SIGTERM');
        // Force kill after 5 more seconds if needed
        setTimeout(() => {
          if (claude.exitCode === null) {
            claude.kill('SIGKILL');
          }
        }, 5000);
        reject(new Error('Claude MCP timed out after 30 seconds'));
      }
    }, 30000); // 30 second timeout
  });
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
        console.log('Claude API overloaded, will retry...');
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
    
    console.log('Successfully got completion from Claude MCP');
    
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
  console.log(`\n📡 Using MCP endpoint: ${MCP_ENDPOINT}`);
  console.log(`✅ Using subscription-authenticated Claude CLI from ~/.claude`);
  console.log(`\n⚠️  Make sure MCP server is running:`);
  console.log(`    claude mcp serve --transport http --port 9090 --dangerously-skip-permissions`);
  console.log(`\n⚠️  Make sure endpoints are registered:`);
  console.log(`    claude mcp add --transport http design-server http://127.0.0.1:9090`);
  console.log(`    claude mcp add --transport http exec-server http://127.0.0.1:9090\n`);
});