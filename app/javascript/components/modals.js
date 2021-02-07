$(document).on('turbolinks:load', function() {
  $('.video-tutorial-wrapper').on('click', function(e) {
    var link = $(this).data('video-tutorial-link');
    $('#default-modal').find(".modal-content").load(link);
    $('#default-modal').modal('show');
    e.preventDefault();
  });
});

$(document).on('turbolinks:load', function() {
  $('.remote-link').on('click', function(e) {
    var link = $(this).attr('href');
    $('#default-modal').find(".modal-content").load(link);
    $('#default-modal').modal('show');
    e.preventDefault();
  });
});

$(document).on('turbolinks:load', function() {
 $('body').on('hidden.bs.modal', '.modal', function () {
   $(this).find('iframe').removeAttr('src');
 });
});

$(document).on('turbolinks:load', function() {

  $('#ecosystem-maps-modal').on('shown.bs.modal', function () {

    var ecosystemMapsModal = $('#ecosystem-maps-modal');
    
    var coords_x = ecosystemMapsModal.data('coords-x');
    var coords_y = ecosystemMapsModal.data('coords-y');

    var modalLeft = coords_x + 30;
    var modalWidth = ecosystemMapsModal.width();

    if (modalLeft + modalWidth > $(window).width()) {
      modalLeft = coords_x - modalWidth - 30;
    }

    var modalTop = coords_y + $(window).scrollTop() - 90;

    var modalHeight = $(this).find('.modal-dialog').outerHeight(true);
    var modalExtent = modalTop + modalHeight;
    var maxHeight = $(window).height() + $(window).scrollTop();
    
    if (modalExtent > maxHeight) {
      modalTop = (maxHeight - modalHeight - 20);
    }

    $('#ecosystem-maps-modal').css('top', modalTop);
    $('#ecosystem-maps-modal').css('left', modalLeft);
    $('#ecosystem-maps-modal').css('opacity', 0.85);
  });
});
