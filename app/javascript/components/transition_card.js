$(document).on('turbolinks:load', function() {
  $(document).on('click', '.show-gaps-button', function() {
    $('.cell').toggleClass('inverse');
  });
});

// Daterange controls

$(document).on('turbolinks:load', function() {
  var dateStart = $('#transition_card_select_date').data('selected-date');

  if (dateStart === undefined) {
    var parsedDateStart = moment()
  } else {
    var parsedDateStart = moment(dateStart, 'YYYY-MM-DD').format('MMMM D, YYYY')
  }

  $('#transition_card_select_date').daterangepicker(
    {
      startDate: parsedDateStart,
      autoApply: true,
      autoUpdateInput: (dateStart !== undefined),
      locale: { format: 'MMMM D, YYYY' },
      singleDatePicker: true,
      showDropdowns: true,
      minYear: 1901,
      maxYear: parseInt(moment().format('YYYY'),10)
    }, 
    function(start, end, label) {
      var scorecardId = $(this.element).data('scorecard-id');
      var date = start.format('YYYY-MM-DD');
      var tags = $.map($('#subsystem-tags').select2('data'), function(v) { return v.text });
      var params = { selected_tags: tags, selected_date: date };
      var url = '/transition_cards/' + scorecardId + '?' + $.param(params);
      $('#spinner-wrapper').css('visibility', 'visible');
      $(location).attr('href', url)
    }
  );

  // $('#transition_card_select_date').on('apply.daterangepicker', function(ev, picker) {
  //   $(this).val(picker.startDate.format("YYYY-MM-DD"));
  // });

  $('#daterange-clear-btn').click(function(e) {
    var scorecardId = $('#transition_card_select_date').data('scorecard-id');
    var tags = $.map($('#subsystem-tags').select2('data'), function(v) { return v.text });
    var params = { selected_tags: tags };
    var url = '/transition_cards/' + scorecardId + '?' + $.param(params);
    $('#spinner-wrapper').css('visibility', 'visible');
    $(location).attr('href', url)   
  });
});
