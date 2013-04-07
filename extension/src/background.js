var uuid = require('node-uuid'),
    hover = {
      active: false,
      channel: uuid.v4()
    };
// Toggle Hover on icon click
chrome.browserAction.onClicked.addListener(function() {
  toggleHover();
  chrome.tabs.getAllInWindow(null, function(tabs){
    for (var i = 0; i < tabs.length; i++) {
      chrome.tabs.sendMessage(tabs[i].id, {event: 'update_socket'});
    }
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
  else if (request.event == 'am_i_selected?') {
    // return {selected: current tab is selected}
    chrome.tabs.getSelected(function (tab) {
      sendResponse({selected: tab.id == sender.tab.id});
    });
  }
  // on long swipe, switch tabs
  else if (request.event == 'tab_gesture') {
    // "natural movement" left long -> next tab
    var direction = (request.gesture == 'left_long') ? 1 : -1;
    // get all tabs to locate current tab and surrounding tabs
    chrome.tabs.getAllInWindow(null, function (tabs) {
      chrome.tabs.getSelected(function (selectedTab) {
        console.log(tabs, selectedTab);
        // locate current tab, and go to next tab)
        for (var i = 0; i < tabs.length; i++) {
          if (tabs[i].id == selectedTab.id) {
            console.log('next tab: ', tabs[(i + direction) % tabs.length]);
            chrome.tabs.update(tabs[(i + direction) % tabs.length].id,
                               {selected: true});
            break;
          }
        }
      });
    });
  }
  return true;
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
