'use strict';

var uuid = require('node-uuid'),
    format = require('util').format,
    config = require('./config'),
    msg = chrome.i18n.getMessage;

// Connect to socket.io server
// io should already be initialized in background.js
var server = config['hover-server'],
    socket = io.connect(format("%s://%s:%d/",
                               server.protocol, server.host, server.port)),
    channel = uuid.v4();

socket.on('connect', function() {
  // 1. Create channel with server
  socket.emit('create_channel', channel);

  // 2. Inject script to display QR code
  require('./render')(channel);

  // 3. Listen for gestures
  socket.on('send_gesture', function(gesture) {
    // just log for now
    console.log(gesture);
  });
});
