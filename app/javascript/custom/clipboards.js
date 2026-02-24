document.addEventListener('DOMContentLoaded', function() {
  new ClipboardJS('.clipboard-btn');

  document.querySelectorAll('a.clipboard-btn').forEach(function(el) {
    el.addEventListener('click', function(e) {
      e.preventDefault();
    });
  });
});
