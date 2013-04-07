'use strict';
var format = require('util').format,
    config = require('./config'),
    injectCode = require('./util').injectCode,
    msg = chrome.i18n.getMessage;

// get status of extension
updateSocket();

// connect to extension for messages
chrome.extension.onMessage.addListener(function (msg, sender, sendResponse) {
  if (msg.event == "display_qr") {
    require('./render')(msg.channel);
  }
  else if (msg.event == "receive_gesture") {
    if (Reveal) Reveal.next();
  }
  else if (msg.event == 'update_socket') {
    updateSocket();
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
      switch (gesture) {
        case 'left':
          injectCode('Reveal.right()');
          break;
        case 'right':
          injectCode('Reveal.left()');
          break;
        case 'up':
          injectCode('Reveal.down()');
          break;
        case 'down':
          injectCode('Reveal.up()');
          break;
        default:
          injectCode('Reveal.toggleOverview()');
          break;
      }
      chrome.runtime.sendMessage({event: 'send_gesture', gesture: gesture}, function (resp) {
      });
      console.log(gesture);
    });
  });
}

function updateSocket() {
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
}
