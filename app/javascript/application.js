// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
//Chartkick
import "chartkick"
import "Chart.bundle"

// JQuery
import jQuery from "jquery";
import "jquery-ujs";
// make jQuery global
window.$ = window.jQuery = jQuery;

import "bootstrap"

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
