// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require Chart.bundle
//= require chartkick
//= require jquery
//= require jquery_ujs
//= require popper
//= require bootstrap
//= require_tree .

$(document).ready(function(){
  var clipboard = new Clipboard('.clipboard-btn', {
    text: function(trigger) {
      if (trigger.getAttribute('data-clipboard-target')) {
        target = trigger.getAttribute('data-clipboard-target').substring(1);
        console.log(target);
        return document.getElementById(target).innerHTML;
      } 
      else if (trigger.getAttribute('data-clipboard-text')) {
        return trigger.getAttribute('data-clipboard-text');
      } 
    }
  });
});
