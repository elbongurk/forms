$(document).on('click', 'table tr[data-url]', function(event) {
  if (!event.target.href) {
    var url = $(event.target).closest("tr").data("url");
    if (url) {
      if (Turbolinks.supported) {
        Turbolinks.visit(url);
      }
      else {
        window.location.href = url;
      }
    }
  }
});

if (Turbolinks.supported) {
  document.addEventListener("turbolinks:load", function() {
    /* Local Time doesn't listen for Turbolinks 5 */
    LocalTime.run();
    /* Gauges doesn't listen for Turbolinks */
    Gauges.run();
  });  
}
else {
  Gauges.run();
}
