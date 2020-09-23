$(document).on('turbolinks:load', function() {
  $('.remote-link').on('click', function(e) {
    var link = $(this).attr('href');
    $('#default-modal').find(".modal-content").load(link);
    $('#default-modal').modal('show');
   // e.preventDefault();
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

$(document).on('turbolinks:load', function() {

  var ecosystemMapsTimer;


  function hideEcosystemMapModal() {
    $('#ecosystem-maps-modal').modal('hide')
  };

  $('#ecosystem-maps-modal').on('show.bs.modal', function () {
    clearTimeout(ecosystemMapsTimer);
  });

  $('#ecosystem-maps-modal').on('shown.bs.modal', function () {

    var ecosystemMapsModal = $('#ecosystem-maps-modal');
    
    var coords_x = ecosystemMapsModal.data('coords-x');
    var coords_y = ecosystemMapsModal.data('coords-y');

    var modalLeft = coords_x + 25;
    var modalWidth = ecosystemMapsModal.width();

    if (modalLeft + modalWidth > $(window).width()) {
      modalLeft = coords_x - modalWidth - 25;
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
    
    ecosystemMapsTimer = setTimeout(hideEcosystemMapModal, 4000);

    $('#ecosystem-maps-modal > .modal-dialog').on("mouseenter", function() {
      clearTimeout(ecosystemMapsTimer);
      ecosystemMapsTimer = null;
    });

    $('#ecosystem-maps-modal > .modal-dialog').on("mouseleave", function() {
      clearTimeout(ecosystemMapsTimer);
      ecosystemMapsTimer = null;
      hideEcosystemMapModal();
    });

    // $("#ecosystem-maps-modal .modal-header").on("mousedown", function(mousedownEvt) {
    //   var $draggable = $(this);
    //   var x = mousedownEvt.pageX - $draggable.offset().left,
    //       y = mousedownEvt.pageY - $draggable.offset().top;
    //   $("body").on("mousemove.draggable", function(mousemoveEvt) {
    //       $draggable.closest(".modal-content").offset({
    //         "left": mousemoveEvt.pageX - x,
    //         "top": mousemoveEvt.pageY - y
    //       });
    //   });
    //   $("body").one("mouseup", function() {
    //       $("body").off("mousemove.draggable");
    //   });
    //   $draggable.closest(".modal").one("bs.modal.hide", function() {
    //       $("body").off("mousemove.draggable");
    //   });
    // });
  });
});
