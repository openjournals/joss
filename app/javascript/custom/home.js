var menuClick, switchTabs;

switchTabs = function() {
  // Remove the 'selected' class from all tabs
  $('.tabnav-tab').removeClass('selected');
  // Add the 'selected' class to this tab
  $(this).addClass('selected');
};

$(document).on('click', '.tabnav-tab', switchTabs);

menuClick = function() {
  // Remove the 'selected' class from all menu link
  $('.menu a').removeClass('selected');
  // Add the 'selected' class to this menu link
  $(this).addClass('selected');
};

$(document).on('click', '.menu a', menuClick);
