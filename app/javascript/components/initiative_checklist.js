/// TODO: This file is not being used. Remove it.
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

  $(document).on('click', '.checklist-comment-remove', function(event) {
    location.reload();
  });
});
