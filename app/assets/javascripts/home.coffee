# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

switchTabs = ->
  target_div = $(this).attr("data-target")

  # Remove the 'selected' class from all tabs
  $('.tabnav-tab').removeClass('selected')

  # Add the 'selected' class from all tabs
  $(this).addClass('selected')

$(document).on 'click', '.tabnav-tab', switchTabs

menuClick = ->
  # Remove the 'selected' class from all tabs
  $('.menu a').removeClass('selected')

  # Add the 'selected' class from all tabs
  $(this).addClass('selected')

$(document).on 'click', '.menu a', menuClick
