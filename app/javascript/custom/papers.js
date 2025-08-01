var authorCheck, setPaperSize;

// Disable the form if the author hasn't checked the certify checkbox
authorCheck = function() {
  var checkBoxCount;
  checkBoxCount = $(".pre-check:checked").length;
  if (checkBoxCount === 3) {
    $("#author-submit").removeClass('disabled');
    $("#author-submit").prop('disabled', false);
  } else {
    $("#author-submit").addClass('disabled');
    $("#author-submit").prop('disabled', true);
  }
};

// Set the height of the paper container when loaded and every time window is resized
setPaperSize = function() {
  var height, paper, paper_container, width;
  if ($("#joss-paper").length > 0) {
    paper_container = $('#joss-paper-pdf-container');
    paper = $('#joss-paper');
    width = paper_container.width();
    height = width * 1.41421;
    paper.css('height', height);
  }
};

$(document).on('change', '.pre-check', authorCheck);

$(window).resize(function() {
  setPaperSize();
});

$(function() {
  $("#joss-paper").on('load', setPaperSize());
  $("form#new_paper").submit(function() {
    e.preventDefault();
  });
});

const copyText = (text) => {
  navigator.clipboard.writeText(text)
}
window.copyText = copyText;

$('#badge-copy-button').popover({
  placement: window.screen.width > 500 ? 'left' : 'bottom'
})