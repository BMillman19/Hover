'use strict';
var uuid = require('node-uuid'),
    format = require('util').format,
    config = require('./config'),
    msg = chrome.i18n.getMessage,
    hover;

if (!chrome.hover) {
  chrome.hover = {
    running: false
  };
}
hover = chrome.hover;
toggleHover();

function toggleHover() {
  if (hover && hover.socket) {
    // disconnect and remove socket if necessary
    if (hover.socket) {
      hover.socket.disconnect();
      delete hover.socket;
    }
    delete hover.channel;
  } else {
    // turn on hover
    initSocket();
  }
}

function initSocket() {
  // Connect to socket.io server
  // io should already be initialized in background.js
  var server = config['hover-server'];
  hover.socket = io.connect(format("%s://%s:%d/",
                                   server.protocol, server.host, server.port));
  hover.channel = uuid.v4();

  var socket = hover.socket;
  socket.on('connect', function() {
    // 1. Create channel with server
    socket.emit('create_channel', hover.channel);

    // 2. Inject script to display QR code
    require('./render')(hover.channel);

    // 3. Listen for gestures
    socket.on('send_gesture', function(gesture) {
      // just log for now
      console.log(gesture);
    });
  });
}
