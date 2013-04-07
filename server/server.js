var config = require('nconf').
    argv().
    env().
    file(__dirname + '/config.json'),
  io = require('socket.io').listen(config.get('hover:port')),
  channels = {},
  connect = require('connect');

// Set log level to info (2))
//io.set('log level', 2);

/**
 * Set up socket.io to host web socket server.
 *  1. Chrome extension connects to websocket to create a channel (UUID generated)
 *  2. Socket waits for second client (controller)
 *  3. Each channel pipes gestures through from the controller to the extension
 * `channels` object:
 *  {
 *    'UUID': {hosts: [tab1, tab2], clients: [controller1, controller2]},
 *    'UUID2': {hosts: [tab3, tab4], clients: [controller3, controller4]}
 *  }
 */
io.sockets.on('connection', function(socket) {
  // 1. Create new channel using UUID; socket = chrome extension
  socket.on('host_channel', function(channel) {
    // hosts are chrome tabs, clients are controllers
    channels[channel] = channels[channel] || {hosts: [], clients: []};
    channels[channel].hosts.push(socket.id);
    console.log(channels);
  });

  // 2. Wait for second client to join; socket = controller
  socket.on('join_channel', function(channel) {
    // If control is connected first, create a new channel
    channels[channel] = channels[channel] || {hosts: [], clients: []};
    var c = channels[channel];
    c.clients.push(socket.id);
    console.log('Channel [' + channel + '] connected:', c);
    c.hosts.forEach(function (host) {
      io.sockets.socket(host).emit('controller_connected');
    });
  });

  // 3. Pipe gestures through from the controller to the extension; socket = controller
  // `gesture` object:
  //  {
  //    channel: someUUID,
  //    payload: ...
  //  }
  socket.on('send_gesture', function(gesture) {
    var channel = channels[gesture.channel];
    console.log(gesture.channel, channels);
    channel.hosts.forEach(function (host) {
      console.log(host);
      io.sockets.socket(host).emit('send_gesture', gesture.payload);
    });
  });

  // Clear up the `channels` array
  // TODO: fix this for new channel format
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
