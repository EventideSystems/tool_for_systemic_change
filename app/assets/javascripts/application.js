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
    $('.wizard').bootstrapWizard({
      tabClass: 'nav nav-pills',
      onTabShow: function(tab, navigation, index) {

        if ($(tab).children().first().attr('href') == '#tab5') {
          
          function fetchWickedProblemDescription(index) {
            $.ajax({
              url: "/wicked_problems/" + index + ".json",
              context: document.body,
              success: function(data) {
                $("#preview-wicked-problem-description").html(data["description"]); 
              }
            });
          };
          
          function fetchCommunityDescription(index) {
            $.ajax({
              url: "/communities/" + index + ".json",
              context: document.body,
              success: function(data) {
                $("#preview-community-description").html(data["description"]); 
              }
            });
          };
          
          var scorecard_name = $('#scorecard_name').val();
          var scorecard_desc = $('#scorecard_description').val();

          if (scorecard_name === "") {
            scorecard_name = '<em style="color:red">Missing</em>'
          }
          
          $("#preview-scorecard-name").html(scorecard_name);
          $("#preview-scorecard-description").html(scorecard_desc);
          
          var wicked_problem_name = $('#scorecard_wicked_problem_id option:selected').text();
          var wicked_problem_id = $('#scorecard_wicked_problem_id').val();
          
          if (wicked_problem_name === "") {
            wicked_problem_name = '<em style="color:red">Missing</em>'
          }
          
          $("#preview-wicked-problem-name").html(wicked_problem_name);
          fetchWickedProblemDescription(wicked_problem_id);
          
          var community_name = $('#scorecard_community_id option:selected').text();
          var community_id = $('#scorecard_community_id').val();
          
          if (community_name === "") {
            community_name = '<em style="color:red">Missing</em>'
          }
          
          $("#preview-community-name").html(community_name);
          fetchCommunityDescription(community_id);
          
          $('ul#preview-initiatives li').remove()
          $('.initiative-name').each(function (index, value) { 
            if ($(value).val() === "") {
              $('ul#preview-initiatives').append('<li><em style="color:red">Name missing</em></li>');
            } else {
              $('ul#preview-initiatives').append('<li>'+$(value).val()+'</li>');
            }
          });
        }
      }
    });
  });
  
  $(document).ready(function() {
    $(".select2").select2();
  });

  $(document).ready(function() {
    $(document).on('click', '.organisation-link', function() {
      $(this).parent().parent().find('select').attr('current', true);
      // $(this).parent().parent().children('.col-md-6').children('.select').children('div.col-sm-9').children('select').attr('current', true);
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
  
  $(document).ready(function() {
    $(document).on('click', '.characteristic-comment', function(event) {
      var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
      $(commentFormId).toggle();
      event.preventDefault();
    });
  });
  
  $(document).ready(function() {
    $(document).on('click', '.btn-checklist-comment-save', function(event) {
      var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
      var characteristicLink = 'a.characteristic-comment[data-id=' + $(this).data('id') + ']';
      $(commentFormId).toggle();
      $(characteristicLink).siblings('span.characteristic-name').addClass('commented');
    });
  });
  
  $(document).ready(function() {
    $(document).on('click', '.btn-checklist-comment-cancel', function(event) {
      var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
      $(commentFormId).toggle();
      event.preventDefault();
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
  
  $(document).ready(function() {
     $('.video-tutorial-wrapper').on('click', function(e) {
       var link = $(this).data('video-tutorial-link');
       $('.modal').find(".modal-content").load(link);
       $('.modal').modal('show');
       e.preventDefault();
     });
  });
  
  
  $(document).ready(function() {
     $('.remote-link').on('click', function(e) {
       var link = $(this).attr('href');
       $('.modal').find(".modal-content").load(link);
       $('.modal').modal('show');
       e.preventDefault();
     });
  });
  
  $(document).ready(function() {
    $('body').on('hidden.bs.modal', '.modal', function () {
      $(this).find('iframe').removeAttr('src');
    });
  });
  
  //= require turbolinks
  //= require_tree .