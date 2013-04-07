var uuid = require('node-uuid'),
    hover = {
      active: false,
      channel: uuid.v4()
    };
// Toggle Hover on icon click
chrome.browserAction.onClicked.addListener(function() {
  toggleHover();
  chrome.tabs.executeScript(null, {
    file: 'hover.js'
  });
});

// Update tabs on changing tabs
chrome.tabs.onActivated.addListener(function(activeInfo) {
  chrome.tabs.executeScript(activeInfo.tabId, {
    file: 'hover.js'
  });
});

// Listen for messages from content script
chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
  console.log(sender.tab ?
              "from a content script:" + sender.tab.url :
              "from the extension");
  if (request.event == 'is_active?') {
    sendResponse(hover);
  }
});

function toggleHover() {
  // if active, change to inactive; vice-versa
  var icon = (hover.active) ? 'hover-inactive.png' : 'hover.png';
  chrome.browserAction.setIcon({path: icon});
  // if inactive -> active, then generate new uuid for channel,
  // also, display qr code
  if (!hover.active) {
    hover.channel = uuid.v4();
    chrome.tabs.getSelected(function (tab) {
      chrome.tabs.sendMessage(tab.id, {event: 'display_qr', channel: hover.channel});
    });
  }
  hover.active = !hover.active;
}