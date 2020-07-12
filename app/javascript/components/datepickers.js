
$(document).on('turbolinks:load', function() {

  $('[data-behaviour~=datepicker]').each(function(){
    element = $(this)
    dropPosition = element.data('datepickerPosition') || 'up'

    element.daterangepicker(
      {
        autoApply: true,
        autoUpdateInput: false,
        locale: { format: "YYYY-MM-DD" },
        singleDatePicker: true,
        showDropdowns: true,
        drops: dropPosition,
        minYear: 1901,
        maxYear: parseInt(moment().format('YYYY'),10)
      }
    );
  });

  $('[data-behaviour~=datepicker]').on('apply.daterangepicker', function(ev, picker) {
    $(this).val(picker.startDate.format("YYYY-MM-DD"));
});
});
