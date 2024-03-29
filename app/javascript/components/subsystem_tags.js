$(document).on('turbolinks:load', function() {
  $('#subsystem-tags').select2({
    allowClear: true,
    formatSelectionCssClass: function (data, container) { return "selected-subsytem-tag"; },
    placeholder: 'Select Subsystem Tags',
    tags: true,
    tokenSeparators: [','],
    ajax: {
      url: '/subsystem_tags.json',
      dataType: 'json',
      data: function (params) {
        var scorecardId = $(this).data('scorecardId');
        var query = {
          search: params.term,
          scorecard_id: scorecardId
        }
        return query;
      },
      processResults: function(data) {
        return { results: data }
      }
    },
  });

  $('#subsystem-tags').on('select2:select select2:unselect', function(e) {
    var tags = $.map($('#subsystem-tags').select2('data'), function(v) { return v.text });
    var date = $('#daterange-btn').data('selectedDate');
    var params = { selected_tags: tags, selected_date: date };

    var url = window.location.pathname + '?' + $.param(params);
    $('#spinner-wrapper').css('visibility', 'visible');
    $(location).attr('href', url)
  });

  $("#subsystem-tags").on("change", function(e) {
    $('.select2-selection__choice:not(.selected-subsystem-tag)', this).addClass('selected-subsystem-tag');
  });
});
