$(document).on('turbolinks:load', function() {
  $(document).on('click', '.characteristic-checkbox', function() {
    $.ajax({
      url: '/initiatives/' +  $(this).data("initiative-id") + '/checklist_items/' + $(this).data("id"),
      type: 'PUT',
      contentType: 'application/json',
      data: JSON.stringify({ checklist_item: { checked: $(this).is(':checked') }}),
      dataType: 'json'
    });
  });
});

$(document).on('turbolinks:load', function() {
  $(document).on('click', '.characteristic-comment', function(event) {
    event.preventDefault();
    console.log('click.characteristic-comment')
    var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
    $(commentFormId).show();
  });

  $('a[data-target="#checklist-items-tab"]').on('shown.bs.tab', function (e) {
    $(document).on('click', '.characteristic-comment', function(event) {
      event.preventDefault();
      console.log('click.characteristic-comment')
      var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
      $(commentFormId).show();
    });
  });
});

$(document).on('turbolinks:load', function() {
  $(document).on('click', '.btn-checklist-comment-save', function(event) {
    var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
    var characteristicLink = 'a.characteristic-comment[data-id=' + $(this).data('id') + ']';
    var comment = $(commentFormId).find('#checklist_item_comment').val();
    
    $(commentFormId).hide();
    if ($.trim(comment).length == 0) {
      $(characteristicLink).siblings('span.characteristic-name').removeClass('commented');
    } else {  
      $(characteristicLink).siblings('span.characteristic-name').addClass('commented');
    }
  });
});

$(document).on('turbolinks:load', function() {
  $(document).on('click', '.btn-checklist-comment-cancel', function(event) {
    event.preventDefault();
    var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
    $(commentFormId).hide();
  });
});
