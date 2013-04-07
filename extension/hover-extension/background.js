var enabled = true;
chrome.browserAction.onClicked.addListener(function() {
  chrome.tabs.executeScript(null, {
    file: 'socket.io.min.js'
  }, function() {
    chrome.tabs.executeScript(null, {
      file: 'hover.js'
    }, function () {
      toggleIcon();
    });
  });
});

function toggleIcon() {
  if (enabled) {
    chrome.browserAction.setIcon({path: 'hover.png'});
  } else {
    chrome.browserAction.setIcon({path: 'hover-inactive.png'});
  }
  enabled = !enabled;
}
