'use strict';
var qrcode = require('qrcode-npm').qrcode,
    config = require('./config'),
    server = config['hover-server'],
    format = require('util').format,
    picoModal = require('./picomodal'),
    msg = chrome.i18n.getMessage;

module.exports = function(channel) {
    var wrapper = document.createElement('div');
    // Remove it when you click on it
    wrapper.addEventListener('click', function() {
        this.parentNode.removeChild( this );
    }, false);

    // Extract socket.io url
    var url = format('%s://%s:%d/!%s',
                     server.protocol,
                     server.host,
                     server.port,
                     channel);
                     console.log(url);

    // Add the "OR"
    var qr = document.createElement('div');
    qr.style.textAlign = 'center';
    wrapper.appendChild(qr);

    // Now create the QRCode
    var qr = qrcode(10, 'M');
    qr.addData(url);
    qr.make();
    wrapper.innerHTML += qr.createImgTag(3);

    var img = wrapper.querySelector('img');
    img.style.margin = '20px auto';
    img.style.display = 'block';

    // Pop up modal
    picoModal(wrapper.innerHTML);
};


