$(document).on('turbolinks:load', function() {
  $('.toast-auto-hide').toast({ autohide: true, delay: 2500 })
  $('.toast-auto-hide').toast('show')
});
