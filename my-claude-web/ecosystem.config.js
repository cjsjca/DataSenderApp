// PM2 configuration for running Claude web interface as a background service
module.exports = {
  apps: [{
    name: 'claude-web',
    script: './server.js',
    
    // Environment variables
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    
    // Process management
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '500M',
    
    // Logging
    error_file: './logs/error.log',
    out_file: './logs/output.log',
    log_file: './logs/combined.log',
    time: true,
    
    // macOS specific optimizations
    exec_mode: 'fork',
    listen_timeout: 3000,
    kill_timeout: 5000
  }]
};