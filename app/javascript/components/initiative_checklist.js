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

  $(document).on('click', '.checklist-comment-new', function(event) {
    var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
    var characteristicLink = 'a.characteristic-comment[data-id=' + $(this).data('id') + ']';
    var commentStatus = $(commentFormId).find('#checklist_item_current_comment_status').val();

    // $(commentFormId).hide();

    $(characteristicLink).siblings('span.characteristic-name').removeClass('actual');
    $(characteristicLink).siblings('span.characteristic-name').removeClass('planned');
    $(characteristicLink).siblings('span.characteristic-name').removeClass('suggestion');
    $(characteristicLink).siblings('span.characteristic-name').removeClass('more-information');

    $(characteristicLink).siblings('checklist-comment-update').prop('disabled', false);
    $(characteristicLink).siblings('checklist-comment-remove').prop('disabled', false);
   
    $(characteristicLink).siblings('span.characteristic-name').addClass(commentStatus)
  });

  $(document).on('click', '.checklist-comment-update', function(event) {
    var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
    var characteristicLink = 'a.characteristic-comment[data-id=' + $(this).data('id') + ']';
    var commentStatus = $(commentFormId).find('#checklist_item_current_comment_status').val();

    // $(commentFormId).hide();

    $(characteristicLink).siblings('span.characteristic-name').removeClass('actual');
    $(characteristicLink).siblings('span.characteristic-name').removeClass('planned');
    $(characteristicLink).siblings('span.characteristic-name').removeClass('suggestion');
    $(characteristicLink).siblings('span.characteristic-name').removeClass('more-information');
   
    $(characteristicLink).siblings('span.characteristic-name').addClass(commentStatus)
  });

  $(document).on('click', '.checklist-comment-remove', function(event) {
    location.reload();
  });
});
