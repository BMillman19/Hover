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
  socket.channel = channel;
  socket.on('connect', function() {
    // Create channel with server
    socket.emit('host_channel', channel);

    // On controller connect, close qr modal
    socket.on('controller_connected', function () {
      injectCode("var a = document.getElementsByClassName('pico-overlay'); for (var i = 0; i < a.length; i++) { a[i].parentNode.removeChild(a[i]) }");
      injectCode("var a = document.getElementsByClassName('pico-content'); for (var i = 0; i < a.length; i++) { a[i].parentNode.removeChild(a[i]) }");
    });

    // Listen for gestures
    socket.on('send_gesture', function(gesture) {
      // just log for now
      console.log(gesture);
      injectCode('if (HOVER_APP) { var fn = HOVER_APP["' + gesture + '"] || function() {}; fn(); }');
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
