const express = require('express');
const bodyParser = require('body-parser');
const { spawn } = require('child_process');
const path = require('path');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware setup - MUST be before routes
app.use(bodyParser.json());
app.use(express.json()); 
app.use(express.static(path.join(__dirname, 'public')));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Helper function to execute Claude with retry logic
async function executeClaudeWithRetry(userPrompt, maxRetries = 3) {
  const delays = [1000, 2000, 4000]; // Exponential backoff delays
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      // Wait before retry (skip on first attempt)
      if (attempt > 0) {
        const delay = delays[attempt - 1];
        console.log(`Retry attempt ${attempt}/${maxRetries} after ${delay}ms delay...`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
      
      // Execute Claude using spawn for better control
      const result = await new Promise((resolve, reject) => {
        // Spawn Claude CLI with proper arguments
        // Note: --dangerously-skip-permissions must come AFTER -p flag
        const claude = spawn('/opt/homebrew/bin/claude', [
          '-p',
          userPrompt,
          '--dangerously-skip-permissions',
          '--output-format',
          'json'
        ], {
          env: process.env, // Inherit all environment variables
          stdio: ['pipe', 'pipe', 'pipe'] // Properly pipe stdin, stdout, stderr
        });
        
        let stdout = '';
        let stderr = '';
        let jsonBuffer = '';
        
        // Handle stdout data - buffer until we have complete JSON
        claude.stdout.on('data', (chunk) => {
          stdout += chunk.toString();
          jsonBuffer += chunk.toString();
          
          // Try to parse complete JSON if we see closing brace
          if (jsonBuffer.includes('}')) {
            try {
              const lines = jsonBuffer.split('\n');
              for (const line of lines) {
                if (line.trim().startsWith('{') && line.trim().endsWith('}')) {
                  const parsed = JSON.parse(line);
                  console.log(`Attempt ${attempt + 1} - Parsed JSON response`);
                  resolve({ stdout: line, stderr, parsed });
                  return;
                }
              }
            } catch (e) {
              // Not complete JSON yet, continue buffering
            }
          }
        });
        
        // Handle stderr data
        claude.stderr.on('data', (chunk) => {
          const data = chunk.toString();
          stderr += data;
          console.error(`Attempt ${attempt + 1} - stderr:`, data);
        });
        
        // Handle process errors
        claude.on('error', (error) => {
          console.error(`Attempt ${attempt + 1} - spawn error:`, error);
          reject(error);
        });
        
        // Handle process close
        claude.on('close', (code) => {
          console.log(`Attempt ${attempt + 1} - Process exited with code ${code}`);
          
          // Check for overloaded error in stderr
          if (stderr.toLowerCase().includes('overloaded')) {
            reject(new Error('OVERLOADED'));
            return;
          }
          
          if (code !== 0) {
            reject(new Error(`Claude exited with code ${code}: ${stderr}`));
          } else if (stdout.trim()) {
            // Try to parse the complete stdout as JSON
            try {
              const parsed = JSON.parse(stdout.trim());
              resolve({ stdout: stdout.trim(), stderr, parsed });
            } catch (e) {
              // If not valid JSON, return raw output
              resolve({ stdout, stderr });
            }
          } else {
            reject(new Error('No output from Claude'));
          }
        });
        
        // Set a timeout to prevent indefinite hanging
        setTimeout(() => {
          console.log(`Attempt ${attempt + 1} - Timeout reached, killing process`);
          claude.kill('SIGTERM');
          setTimeout(() => {
            if (!claude.killed) {
              claude.kill('SIGKILL');
            }
          }, 5000);
        }, 30000); // 30 second timeout
      });
      
      // If we got here, command succeeded
      return result;
      
    } catch (error) {
      // If it's not an overloaded error or we're out of retries, throw
      if (error.message !== 'OVERLOADED' || attempt === maxRetries) {
        throw error;
      }
      // Otherwise, continue to next retry
    }
  }
}

// Main Claude API endpoint
app.post('/api/claude', async (req, res) => {
  console.log('=> got:', req.body);
  const { text } = req.body;
  
  // Set request timeout to 40 seconds
  req.setTimeout(40000);
  
  // Validate input
  if (!text) {
    return res.status(400).json({ error: 'Missing text field' });
  }

  console.log('Executing Claude CLI with prompt:', text);
  
  try {
    // Execute with retry logic
    const result = await executeClaudeWithRetry(text);
    
    // Extract completion from the response
    let completion = '';
    
    if (result.parsed) {
      // Successfully parsed JSON response
      completion = result.parsed.result || result.parsed.completion || result.parsed.content || '';
    } else if (result.stdout) {
      // Fallback to raw output if JSON parsing failed
      completion = result.stdout;
    }
    
    console.log('Successfully got completion');
    res.json({ completion });
    
  } catch (error) {
    console.error('Final error after retries:', error);
    
    // Check if it was an overloaded error
    if (error.message === 'OVERLOADED' || error.message.toLowerCase().includes('overloaded')) {
      return res.status(503).json({ 
        error: 'Service overloaded, please try again later' 
      });
    }
    
    // Other errors
    return res.status(500).json({ 
      error: error.message || 'Failed to execute Claude CLI' 
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server - bind to localhost only for security
app.listen(PORT, '127.0.0.1', () => {
  console.log(`Claude web interface running at http://localhost:${PORT}`);
  console.log(`Health check available at http://localhost:${PORT}/health`);
  console.log('Using subscription-authenticated Claude CLI from ~/.claude');
  console.log('Make sure you have run "claude --dangerously-skip-permissions" once to accept prompts');
});