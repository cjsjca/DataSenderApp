const express = require('express');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const path = require('path');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware setup
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Main Claude API endpoint
app.post('/api/claude', (req, res) => {
  const { text } = req.body;
  
  // Validate input
  if (!text) {
    return res.status(400).json({ error: 'Missing text field' });
  }

  // Escape quotes and special characters for shell command
  const escapedText = text.replace(/"/g, '\\"').replace(/\$/g, '\\$');
  
  // Execute Claude CLI in print mode with JSON output
  // Note: Requires ANTHROPIC_API_KEY environment variable or authenticated CLI session
  const command = `claude -p "${escapedText}" --output-format json`;
  
  // Set timeout for long-running requests
  const options = {
    timeout: 60000, // 60 seconds
    maxBuffer: 1024 * 1024 * 10 // 10MB buffer
  };
  
  console.log('Executing command:', command);
  
  exec(command, options, (error, stdout, stderr) => {
    console.log('Command completed');
    console.log('Error:', error);
    console.log('Stdout:', stdout);
    console.log('Stderr:', stderr);
    
    if (error) {
      console.error('Claude execution error:', error.message);
      console.error('stderr:', stderr);
      return res.status(500).json({ 
        error: stderr || error.message || 'Failed to execute Claude CLI' 
      });
    }

    try {
      // Parse JSON response from Claude
      const response = JSON.parse(stdout);
      const completion = response.completion || response.content || '';
      
      res.json({ completion });
    } catch (parseError) {
      console.error('JSON parse error:', parseError);
      console.error('stdout:', stdout);
      // If JSON parsing fails, return raw output
      res.json({ completion: stdout });
    }
  });
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
  
  // Check if API key is set
  if (!process.env.ANTHROPIC_API_KEY) {
    console.warn('Warning: ANTHROPIC_API_KEY not set. Claude CLI must be authenticated via OAuth.');
  }
});