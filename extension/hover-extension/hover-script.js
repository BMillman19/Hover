// Detect if hover is active
chrome.runtime.sendMessage({topic: 'is_active'}, function (running) {
  if (running) {
    // Check if website is hover-aware
    var app = window.HOVER_APP;
    if (app && typeof app === 'object') {
      console.log('Hover application detected');
    } else {
      console.log('No hover app detected');
    }
  }
});
