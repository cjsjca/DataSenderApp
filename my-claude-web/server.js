const express = require('express');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const path = require('path');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware setup
app.use(bodyParser.json());
app.use(express.json()); // Also support express.json() 
app.use(express.static(path.join(__dirname, 'public')));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Helper function to execute Claude with retry logic
async function executeClaudeWithRetry(command, options, maxRetries = 3) {
  const delays = [1000, 2000, 4000]; // Exponential backoff delays
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      // Wait before retry (skip on first attempt)
      if (attempt > 0) {
        const delay = delays[attempt - 1];
        console.log(`Retry attempt ${attempt}/${maxRetries} after ${delay}ms delay...`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
      
      // Execute command using spawn for better control
      const result = await new Promise((resolve, reject) => {
        const { spawn } = require('child_process');
        const args = ['--dangerously-skip-permissions', '-p', command.match(/"([^"]*)"/)[1], '--output-format', 'json'];
        const claude = spawn('/opt/homebrew/bin/claude', args, options);
        
        let stdout = '';
        let stderr = '';
        
        claude.stdout.on('data', (data) => {
          stdout += data.toString();
        });
        
        claude.stderr.on('data', (data) => {
          stderr += data.toString();
        });
        
        claude.on('close', (code) => {
          console.log(`Attempt ${attempt + 1} - Exit code: ${code}, stderr: ${stderr}, stdout: ${stdout}`);
          
          // Check for overloaded error
          if (code !== 0 || stderr) {
            const errorMessage = stderr || '';
            if (errorMessage.toLowerCase().includes('overloaded')) {
              reject(new Error('OVERLOADED'));
              return;
            }
          }
          
          if (code !== 0) {
            reject(new Error(`Claude exited with code ${code}`));
          } else {
            resolve({ stdout, stderr });
          }
        });
        
        // Kill the process after 20 seconds if it hasn't completed
        setTimeout(() => {
          claude.kill('SIGTERM');
        }, 20000);
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
  
  // Set request timeout to 35 seconds
  req.setTimeout(35000);
  
  // Validate input
  if (!text) {
    return res.status(400).json({ error: 'Missing text field' });
  }

  // Escape quotes and special characters for shell command
  const escapedText = text.replace(/"/g, '\\"').replace(/\$/g, '\\$').replace(/`/g, '\\`');
  
  // Execute Claude CLI in print mode with JSON output
  // Uses existing authenticated CLI session from ~/.claude
  // Note: Using full path and --dangerously-skip-permissions flag
  const command = `/opt/homebrew/bin/claude --dangerously-skip-permissions -p "${escapedText}" --output-format json`;
  
  // Set execution options (no timeout for debugging)
  const options = {
    maxBuffer: 1024 * 1024 * 10, // 10MB buffer
    env: { ...process.env, PATH: process.env.PATH } // Ensure PATH is inherited
  };
  
  console.log('Executing command:', command);
  
  try {
    // Execute with retry logic
    const { stdout, stderr } = await executeClaudeWithRetry(command, options);
    
    // Parse JSON response from Claude
    try {
      const response = JSON.parse(stdout);
      const completion = response.result || response.completion || response.content || '';
      
      res.json({ completion });
    } catch (parseError) {
      console.error('JSON parse error:', parseError);
      console.error('stdout was:', stdout);
      // If JSON parsing fails but we have output, return it as-is
      if (stdout.trim()) {
        res.json({ completion: stdout });
      } else {
        res.status(500).json({ error: 'Failed to parse Claude response' });
      }
    }
    
  } catch (error) {
    console.error('Final error after retries:', error);
    
    // Check if it was an overloaded error
    const errorMessage = (error?.message || '') + (error?.stderr || '');
    if (errorMessage.toLowerCase().includes('overloaded')) {
      return res.status(503).json({ 
        error: 'Service overloaded, please try again later' 
      });
    }
    
    // Other errors
    return res.status(500).json({ 
      error: error.stderr || error.message || 'Failed to execute Claude CLI' 
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
});