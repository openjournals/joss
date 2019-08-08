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

setPaperSize = ->
  if($("#joss-paper").length > 0)
    paper = $('#joss-paper')
    width = paper.width()
    height = width * 1.41421
    paper.css('height', height)

$(document).on 'change', '.pre-check', authorCheck

$(window).resize ->
  setPaperSize()

$ ->
  setPaperSize()

  $("form#new_paper").submit ->
    e.preventDefault()

  if (typeof Clipboard != 'undefined')
    clipboard = new Clipboard('.clippy')
