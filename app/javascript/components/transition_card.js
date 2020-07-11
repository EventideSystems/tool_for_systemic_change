$(document).on('turbolinks:load', function() {
  $(document).on('click', '.show-gaps-button', function() {
    $('.cell').toggleClass('inverse');
  });
});

