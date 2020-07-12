$(document).on('turbolinks:load', function() {
  $(document).on('click', '.show-gaps-button', function() {
    $('.cell').toggleClass('inverse');
  });
});

// Daterange controls

$(document).on('turbolinks:load', function() {
    var dateStart = $('#daterange-btn').data('selected-date');

    if (dateStart === undefined) {
      var parsedDateStart = moment()
    } else {
      var parsedDateStart = moment(dateStart, 'YYYY-MM-DD').format('MMMM D, YYYY')
    }

    $('#daterange-btn').daterangepicker(
        {
          locale: {
            format: 'MMMM D, YYYY'
          },
          startDate: parsedDateStart,
          opens: 'right',
          singleDatePicker: true,
        },
        function (start, end) {
          $('#daterange-btn span').html(start.format('MMMM D, YYYY'));
        }
    );
    
    $('#daterange-btn').on('apply.daterangepicker', function(ev, picker) {
      var scorecardId = $(picker.element).data('scorecard-id');
      var date = picker.startDate.format('YYYY-MM-DD');
      var tags = $.map($('#subsystem-tags').select2('data'), function(v) { return v.text });
      
      var params = { selected_tags: tags, selected_date: date };
      
      var url = '/transition_cards/' + scorecardId + '?' + $.param(params);
      $(location).attr('href', url)
    });
    
    $('#daterange-clear-btn').click(function(e) {
      var scorecardId = $('#daterange-btn').data('scorecardId')
      var tags = $.map($('#subsystem-tags').select2('data'), function(v) { return v.text });
      var params = { selected_tags: tags };
      var url = '/transition_cards/' + scorecardId + '?' + $.param(params);
      $(location).attr('href', url)   
    });
  });
