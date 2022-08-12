document.addEventListener('page:change', function() {
    document.getElementById('primary-content').className += 'animated fadeIn';
});
document.addEventListener('page:fetch', function() {
    document.getElementById('primary-content').className += 'animated fadeOut';
});