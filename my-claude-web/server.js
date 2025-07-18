const express = require('express');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const path = require('path');

const app = express();
const PORT = 3000;

// Middleware
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

// POST endpoint for Claude
app.post('/api/claude', (req, res) => {
  const { text } = req.body;
  
  if (!text) {
    return res.status(400).json({ error: 'Missing text field' });
  }

  // Escape quotes for shell command
  const escapedText = text.replace(/"/g, '\\"');
  
  // Execute Claude CLI in print mode with JSON output
  const command = `claude -p "${escapedText}" --output-format json`;
  
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error('Error executing Claude:', error);
      return res.status(500).json({ error: stderr || error.message });
    }

    try {
      // Parse JSON response from Claude
      const response = JSON.parse(stdout);
      const completion = response.completion || '';
      
      res.json({ completion });
    } catch (parseError) {
      console.error('Error parsing Claude response:', parseError);
      res.status(500).json({ error: 'Failed to parse Claude response' });
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Claude web interface running at http://localhost:${PORT}`);
});