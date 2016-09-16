# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Disable the form if the author hasn't checked the certify checkbox
authorCheck = ->
  if $("#author-check:checked").length > 0
    $("#author-submit").toggleClass('disabled')
    $("#author-submit").prop('disabled', false)
  else
    $("#author-submit").toggleClass('disabled')
    $("#author-submit").prop('disabled', true)

$(document).on 'change', '#author-check', authorCheck

$ ->
  $("form#new_paper").submit ->
    e.preventDefault()
