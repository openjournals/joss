$(function() {
  var select = $("#editor_kind");
  select.on("change", function() {
    if (this.value == "board") {
      $("#editor_title").removeAttr("disabled");
    } else {
      $("#editor_title").attr("disabled", "disabled");
    }
  });
});
