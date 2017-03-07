// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
  
  //= require jquery
  //= require bootstrap-sprockets
  //= require jquery_ujs
  //= require nested_form_fields

  //= require adminlte
  //= require select2
  //= require medium-editor
  //= require twitter-bootstrap-wizard
  
  var ready = function () {
    var o;
    o = $.AdminLTE.options;
    if (o.sidebarPushMenu) {
      $.AdminLTE.pushMenu.activate(o.sidebarToggleSelector);
    }
    return $.AdminLTE.layout.activate();
  };
  
  $( document ).ready(function() {
    document.addEventListener('turbolinks:load', ready);
  });
  
  $( document ).ready(function() {
    var editor = new MediumEditor('.textarea', {buttonLabels: 'bootstrap'});
  });
  
  $(document).ready(function() {
    $('.wizard').bootstrapWizard({'tabClass': 'nav nav-pills'});
  });
  
  $(document).ready(function() {
    $(".select2").select2();
  });

  $(document).ready(function() {
    $(document).on('click', '.organisation-link', function() {
      $(this).siblings('.select').children('select').attr('current', true);
    });
  });
  
  $(document).ready(function() {
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
  
  $(document).ready(function(){
    $(document).on('click', '.show-gaps-button', function() {
      $('.cell').toggleClass('inverse');
    });
  });
  
  $(document).ready(function() {
    $('a.link-disabled').click(function(event){
      event.preventDefault(); // Prevent link from following its href
    });
  });
  //= require turbolinks
  //= require_tree .