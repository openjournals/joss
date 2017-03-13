# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Disable the form if the author hasn't checked the certify checkbox
authorCheck = ->
  checkBoxCount = $(".pre-check:checked").length
  if checkBoxCount == 2
    $("#author-submit").removeClass('disabled')
    $("#author-submit").prop('disabled', false)
  else
    $("#author-submit").addClass('disabled')
    $("#author-submit").prop('disabled', true)

$(document).on 'change', '.pre-check', authorCheck

$ ->
  $("form#new_paper").submit ->
    e.preventDefault()
