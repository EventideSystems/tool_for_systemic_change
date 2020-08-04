$(document).on('turbolinks:load', function() {
  $('.remote-link').on('click', function(e) {
    var link = $(this).attr('href');
    $('.modal').find(".modal-content").load(link);
    $('.modal').modal('show');
    e.preventDefault();
  });
});

$(document).on('turbolinks:load', function() {
 $('body').on('hidden.bs.modal', '.modal', function () {
   $(this).find('iframe').removeAttr('src');
 });
});

$(document).on('turbolinks:load', function() {
  $('.video-tutorial-wrapper').on('click', function(e) {
    var link = $(this).data('video-tutorial-link');
    $('.modal').find(".modal-content").load(link);
    $('.modal').modal('show');
    e.preventDefault();
  });
});
