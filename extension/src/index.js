'use strict';
var format = require('util').format,
    config = require('./config'),
    msg = chrome.i18n.getMessage;

// get status of extension
chrome.runtime.sendMessage({event: 'is_active?'}, function (resp) {
  // initialize socket to already active channel if active
  if (resp.active && !chrome.socket) {
    initSocket(resp.channel);
  }
  // otherwise disconnect socket
  else if (chrome.socket) {
    chrome.socket.disconnect();
    delete chrome.socket;
  }
});

// connect to extension for messages
chrome.extension.onMessage.addListener(function (msg, sender, sendResponse) {
  if (msg.event == "display_qr") {
    require('./render')(msg.channel);
  }
});

function initSocket(channel) {
  // Connect to socket.io server
  // io should already be initialized in background.js
  var server = config['hover-server'];
  console.log('Connected to hover socket on channel: ' + channel);
  chrome.socket = io.connect(format("%s://%s:%d/",
                                   server.protocol, server.host, server.port));
  var socket = chrome.socket;
  socket.on('connect', function() {
    // 1. Create channel with server
    socket.emit('host_channel', channel);

    // 3. Listen for gestures
    socket.on('send_gesture', function(gesture) {
      // just log for now
      console.log(gesture);
    });
  });
}
