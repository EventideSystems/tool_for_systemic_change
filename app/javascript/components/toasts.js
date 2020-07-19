$(document).on('turbolinks:load', function() {
  $('.toast').toast({autohide: true, delay: 2500})
  $('.toast').toast('show')
});
