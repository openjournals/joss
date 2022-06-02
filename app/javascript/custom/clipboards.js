$(document).ready(function(){
  var clipboard;
  if (typeof ClipboardJS !== 'undefined') {
    clipboard = new ClipboardJS('.clipboard-btn', {
      text: function(trigger) {
        if (trigger.getAttribute('data-clipboard-target')) {
          var target = trigger.getAttribute('data-clipboard-target').substring(1);
          return document.getElementById(target).innerHTML;
        }
        else if (trigger.getAttribute('data-clipboard-text')) {
          return trigger.getAttribute('data-clipboard-text');
        }
      }
    });
  }
});
