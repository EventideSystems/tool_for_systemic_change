$(document).on('turbolinks:load', function() {
  $('div.organisations').on('cocoon:before-remove', function(event, removedNode) {    
    if ($(removedNode).find('.assign-organisation-select').val() == "") {
      event.preventDefault();
    }
  });

  $('div.subsystem_tags').on('cocoon:before-remove', function(event, removedNode, xxx) {    
    if ($(removedNode).find('.assign-subsystem-tag-select').val() == "") {
      event.preventDefault();
    }
  });
});

$(document).on('turbolinks:load', function() {
  $('div.organisations').on('cocoon:after-insert', function(event, node) {    
    node.on('change', function(e) {
      var emptyFormCount = $('.assign-organisation-select').filter(
        function(){return $(this).val() == ''}
      ).length;
      
      if (emptyFormCount == 0) {
        $("[data-association='initiatives_organisation']")[0].click();
      }
    });
  });

  $('div.subsystem_tags').on('cocoon:after-insert', function(event, node) {    
    node.on('change', function(e) {
      var emptyFormCount = $('.assign-subsystem-tag-select').filter(
        function(){return $(this).val() == ''}
      ).length;
      
      if (emptyFormCount == 0) {
        $("[data-association='initiatives_subsystem_tag']")[0].click();
      }
    });
  });
});

$(document).on('turbolinks:load', function() {
  $('select.assign-organisation-select').on('change', function(e) {
    var emptyFormCount = $('.assign-organisation-select').filter(
      function(){return $(this).val() == ''}
    ).length;
    
    if (emptyFormCount == 0) {
      $("[data-association='initiatives_organisation']")[0].click();
    }
  });
});

$(document).on('turbolinks:load', function() {
  $('select.assign-subsystem-tag-select').on('change', function(e) {
    var emptyFormCount = $('.assign-subsystem-tag-select').filter(
      function(){return $(this).val() == ''}
    ).length;
    
    if (emptyFormCount == 0) {
      $("[data-association='initiatives_subsystem_tag']")[0].click();
    }
  });
});
