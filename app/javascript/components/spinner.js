$(document).on('turbolinks:load', function() {
  $('[data-behaviour~=show-spinner]').on('click', function() {
    $('#spinner-wrapper').css('visibility', 'visible');
  });
});
