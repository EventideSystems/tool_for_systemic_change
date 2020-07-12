$(document).on('turbolinks:load', function() {
  $('.toast').toast({autohide: true, delay: 3000})
  $('.toast').toast('show')
});
