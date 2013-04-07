module.exports = {
  injectCode: function(code) {
    var script = document.createElement('script');
    script.textContent = code;
    document.body.appendChild(script);
    script.parentNode.removeChild(script);
  }
};
