const express = require('express');
const pty = require('node-pty');
const path = require('path');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware setup - MUST be before routes
app.use(express.json()); // Parse JSON request bodies
app.use(express.static(path.join(__dirname, 'public'))); // Serve static files

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Function to run Claude CLI with pseudo-TTY
async function runClaude(promptText) {
  return new Promise((resolve, reject) => {
    console.log(`Spawning Claude CLI with prompt: "${promptText}"`);
    
    // Spawn Claude with a pseudo-TTY
    const ptyProcess = pty.spawn('/opt/homebrew/bin/claude', [
      '-p',
      promptText,
      '--dangerously-skip-permissions',
      '--output-format',
      'json'
    ], {
      name: 'xterm-color',
      cwd: process.cwd(),
      env: process.env
    });
    
    let buffer = '';
    let hasResolved = false;
    
    // Handle data from the PTY
    ptyProcess.onData((data) => {
      buffer += data;
      console.log('PTY data chunk:', data);
      
      // Try to parse JSON from buffer
      // Look for complete JSON objects in the buffer
      const lines = buffer.split('\n');
      for (const line of lines) {
        const trimmed = line.trim();
        if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
          try {
            const parsed = JSON.parse(trimmed);
            console.log('Successfully parsed JSON:', parsed);
            
            // Extract completion from various possible fields
            const completion = parsed.result || 
                             parsed.completion || 
                             parsed.content || 
                             parsed.output || 
                             '';
            
            hasResolved = true;
            ptyProcess.kill();
            resolve(completion);
            return;
          } catch (e) {
            // Not valid JSON, continue
          }
        }
      }
    });
    
    // Handle PTY exit
    ptyProcess.onExit((exitCode) => {
      console.log(`PTY process exited with code: ${exitCode}`);
      if (!hasResolved) {
        if (exitCode === 0) {
          reject(new Error('Claude exited without producing valid JSON output'));
        } else {
          reject(new Error(`Claude exited with code ${exitCode}`));
        }
      }
    });
    
    // Set a timeout to prevent hanging forever
    setTimeout(() => {
      if (!hasResolved) {
        console.log('Timeout reached, killing PTY process');
        hasResolved = true;
        ptyProcess.kill();
        reject(new Error('Claude CLI timed out after 30 seconds'));
      }
    }, 30000); // 30 second timeout
  });
}

// Function to run Claude with retry logic
async function runClaudeWithRetry(promptText, maxRetries = 3) {
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
      const completion = await runClaude(promptText);
      return completion;
      
    } catch (error) {
      console.error(`Attempt ${attempt + 1} failed:`, error.message);
      
      // Check if it's an overloaded error
      if (error.message && error.message.toLowerCase().includes('overloaded')) {
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
    const completion = await runClaudeWithRetry(text);
    
    console.log('Successfully got completion from Claude');
    
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
  console.log(`\n🚀 Claude Web Interface Server (with PTY support)`);
  console.log(`📍 Running at: http://localhost:${PORT}`);
  console.log(`🔧 Health check: http://localhost:${PORT}/health`);
  console.log(`\n✅ Using subscription-authenticated Claude CLI from ~/.claude`);
  console.log(`✅ Using node-pty for proper TTY emulation`);
  console.log(`⚠️  Make sure you've run 'claude --dangerously-skip-permissions' once interactively\n`);
});