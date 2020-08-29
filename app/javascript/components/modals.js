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

  $('#ecosystem-maps-modal').on('shown.bs.modal', function () {

    // $(document).off('focusin.bs.modal');

    var ecosystemMapsTimer;

    function hideEcosystemMapModal() {
      $('#ecosystem-maps-modal').modal('hide')
    };

    console.log('starting timer');
    ecosystemMapsTimer = setTimeout(hideEcosystemMapModal, 3000);

    $('#ecosystem-maps-modal > .modal-dialog').on("mouseenter", function() {
      console.log('mouseenter');
      clearTimeout(ecosystemMapsTimer);
       ecosystemMapsTimer = null;
    });

    $('#ecosystem-maps-modal > .modal-dialog').on("mouseleave", function() {
      console.log('mouseleave');
      clearTimeout(ecosystemMapsTimer);
      ecosystemMapsTimer = setTimeout(hideEcosystemMapModal, 2000)
    });
  });
});
