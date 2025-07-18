const express = require('express');
const { spawn } = require('child_process');
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

// Helper function to spawn Claude with retry logic
async function spawnClaudeWithRetry(userPrompt, maxRetries = 3) {
  const delays = [1000, 2000, 4000]; // Exponential backoff delays in ms
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      // Wait before retry (skip on first attempt)
      if (attempt > 0) {
        const delay = delays[attempt - 1];
        console.log(`Retrying after ${delay}ms (attempt ${attempt + 1}/${maxRetries + 1})...`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
      
      // Spawn Claude and get result
      const result = await new Promise((resolve, reject) => {
        console.log(`Spawning Claude CLI (attempt ${attempt + 1})...`);
        
        // Spawn the Claude CLI process
        const claude = spawn('/opt/homebrew/bin/claude', [
          '-p',
          userPrompt,
          '--dangerously-skip-permissions',
          '--output-format',
          'json'
        ], {
          env: process.env, // Inherit all environment variables including HOME for ~/.claude
          stdio: ['pipe', 'pipe', 'pipe'] // Pipe stdin, stdout, stderr
        });
        
        let stdoutBuffer = '';
        let stderrBuffer = '';
        let hasResolved = false;
        
        // Handle stdout data
        claude.stdout.on('data', (chunk) => {
          stdoutBuffer += chunk.toString();
          
          // Try to parse JSON if we have what looks like a complete object
          const trimmed = stdoutBuffer.trim();
          if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
            try {
              const parsed = JSON.parse(trimmed);
              console.log('Successfully parsed JSON response');
              hasResolved = true;
              resolve({ json: parsed, stderr: stderrBuffer });
            } catch (e) {
              // Not valid JSON yet, keep buffering
            }
          }
        });
        
        // Handle stderr data
        claude.stderr.on('data', (chunk) => {
          const data = chunk.toString();
          stderrBuffer += data;
          console.error('Claude stderr:', data);
        });
        
        // Handle process errors
        claude.on('error', (error) => {
          console.error('Claude spawn error:', error);
          if (!hasResolved) {
            hasResolved = true;
            reject(new Error(`Failed to spawn Claude: ${error.message}`));
          }
        });
        
        // Handle process close
        claude.on('close', (code) => {
          if (!hasResolved) {
            console.log(`Claude process exited with code ${code}`);
            
            // Check for overloaded error in stderr
            if (stderrBuffer.toLowerCase().includes('overloaded')) {
              reject(new Error('OVERLOADED'));
            } else if (code !== 0) {
              reject(new Error(`Claude exited with code ${code}: ${stderrBuffer || 'No error output'}`));
            } else {
              // Process succeeded but no JSON was captured
              reject(new Error('No valid JSON response from Claude'));
            }
          }
        });
        
        // Timeout after 30 seconds to prevent hanging
        setTimeout(() => {
          if (!hasResolved) {
            console.log('Timeout reached, terminating Claude process');
            claude.kill('SIGTERM');
            // Force kill after 5 more seconds if needed
            setTimeout(() => {
              if (!hasResolved) {
                claude.kill('SIGKILL');
              }
            }, 5000);
          }
        }, 30000);
      });
      
      // Success - return the result
      return result;
      
    } catch (error) {
      // Check if it's an overloaded error
      if (error.message === 'OVERLOADED') {
        console.log('Claude API overloaded, will retry...');
        // Continue to next retry unless we're out of attempts
        if (attempt === maxRetries) {
          throw new Error('SERVICE_OVERLOADED');
        }
      } else {
        // Other errors - throw immediately
        throw error;
      }
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
    const result = await spawnClaudeWithRetry(text);
    
    // Extract completion from the JSON response
    const completion = result.json.result || 
                      result.json.completion || 
                      result.json.content || 
                      result.json.output || 
                      '';
    
    // Log successful completion
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
  console.log(`\n🚀 Claude Web Interface Server`);
  console.log(`📍 Running at: http://localhost:${PORT}`);
  console.log(`🔧 Health check: http://localhost:${PORT}/health`);
  console.log(`\n✅ Using subscription-authenticated Claude CLI from ~/.claude`);
  console.log(`⚠️  Make sure you've run 'claude --dangerously-skip-permissions' once interactively\n`);
});