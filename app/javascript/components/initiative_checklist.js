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
    var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
    $(commentFormId).find('#checklist_item_new_comment').val('');
    $(commentFormId).show();

    $(commentFormId).find('textarea').each(function () {
      this.setAttribute('style', 'height:' + (this.scrollHeight) + 'px;overflow-y:hidden;');
    }).on('input', function () {
      this.style.height = 'auto';
      this.style.height = (this.scrollHeight) + 'px';
    });
  });

  $('a[data-target="#checklist-items-tab"]').on('shown.bs.tab', function (e) {
    $(document).on('click', '.characteristic-comment', function(event) {
      event.preventDefault();
      var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
      $(commentFormId).find('#checklist_item_new_comment').val('');
      $(commentFormId).show();
    });
  });
});

$(document).on('turbolinks:load', function() {

  $(document).on('click', '.btn-checklist-comment-update-current', function(event) {
    var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
    var characteristicLink = 'a.characteristic-comment[data-id=' + $(this).data('id') + ']';
    var currentComment = $(commentFormId).find('#checklist_item_current_comment').val();
    var newComment = $(commentFormId).find('#checklist_item_new_comment').val();
    var commentStatus = $(commentFormId).find('#checklist_item_current_comment_status').val();
    

    $(commentFormId).hide();

    $(characteristicLink).siblings('span.characteristic-name').removeClass('actual');
    $(characteristicLink).siblings('span.characteristic-name').removeClass('planned');
    $(characteristicLink).siblings('span.characteristic-name').removeClass('suggestion');
    $(characteristicLink).siblings('span.characteristic-name').removeClass('more-information');
   
    $(characteristicLink).siblings('span.characteristic-name').addClass(commentStatus)
  });

  $(document).on('click', '.btn-checklist-comment-create-new', function(event) {
    var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
    var characteristicLink = 'a.characteristic-comment[data-id=' + $(this).data('id') + ']';
    var currentComment = $(commentFormId).find('#checklist_item_current_comment').val();
    var newComment = $(commentFormId).find('#checklist_item_new_comment').val();
    var commentStatus = $(commentFormId).find('#checklist_item_new_comment_status').val()
    
    $(commentFormId).find('#checklist_item_current_comment').val(newComment);

    $(commentFormId).find('.characteristic-update-comment-form').show();

    $(commentFormId).hide();

    $(characteristicLink).siblings('span.characteristic-name').removeClass('actual');
    $(characteristicLink).siblings('span.characteristic-name').removeClass('planned');
    $(characteristicLink).siblings('span.characteristic-name').removeClass('suggestion');
    $(characteristicLink).siblings('span.characteristic-name').removeClass('more-information');

    $(characteristicLink).siblings('span.characteristic-name').addClass(commentStatus)
  });
});

$(document).on('turbolinks:load', function() {
  $(document).on('click', '.btn-checklist-comment-cancel', function(event) {
    event.preventDefault();
    var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
    $(commentFormId).hide();
  });
});
