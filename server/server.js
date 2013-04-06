console.log(__dirname);
var config = require('nconf').
    argv().
    env().
    file(__dirname + '/config.json'),
  io = require('socket.io').listen(config.get('hover:port')),
  channels = {},
  connect = require('connect');

// Set log level to info (2))
io.set('log level', 2);

/**
 * Set up socket.io to host web socket server.
 *  1. Chrome extension connects to websocket to create a channel (UUID generated)
 *  2. Socket waits for second client (controller)
 *  3. Each channel pipes gestures through from the controller to the extension
 * `channels` object:
 *  {
 *    'UUID': [ client1, client2 ],
 *    'UUID2': [ client3, client4 ]
 *  }
 */
io.sockets.on('connection', function(socket) {
  // 1. Create new channel using UUID; socket = chrome extension
  socket.on('create_channel', function(channel) {
      channels[channel] = [];
      channels[channel].push(socket.id);
  });

  // 2. Wait for second client to join; socket = controller
  socket.on('join_channel', function(channel) {
    // If control is connected first, create a new channel
    channels[channel] = channels[channel] || [];
    channels[channel].push(socket.id);
  });

  // 3. Pipe gestures through from the controller to the extension; socket = controller
  // `gesture` object:
  //  {
  //    channel: someUUID,
  //    payload: ...
  //  }
  socket.on('send_gesture', function(gesture) {
    var channel = channels[obj.channel];
    var target = channel[0];  // first client in channel should be the extension
    io.sockets.socket(target).emit('send_gesture', gesture.payload);
  });

  // Clear up the `channels` array
  socket.on('disconnect', function() {
    // Remove the channel in which the client just disconnected
    Object.keys(channels).forEach(function(channel) {
      var index = channel.indexOf(socket.id);
      if (~index) {
        delete channels[channel];
      }
    });
  });
});

connect.createServer(
  connect.static(__dirname + '/public')
).listen(config.get('hover:http_port'));
