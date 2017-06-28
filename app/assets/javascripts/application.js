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
  //= require bootstrap-datepicker
  //= require adminlte
  //= require select2
  //= require medium-editor
  //= require twitter-bootstrap-wizard
  //= require moment
  //= require bootstrap-daterangepicker
  
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
    $(".select2").select2();
  });

  $(document).ready(function() {
    $(document).on('click', '.organisation-link', function() {
      $(this).parent().parent().find('select').attr('current', true);
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
      var comment = $(commentFormId).find('#checklist_item_comment').val();
      debugger;
      $(commentFormId).toggle();
      if ($.trim(comment).length == 0) {
        $(characteristicLink).siblings('span.characteristic-name').removeClass('commented');
      } else {  
        $(characteristicLink).siblings('span.characteristic-name').addClass('commented');
      }
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
  

  
  $(document).ready(function() {
    $('.initiative-detail-scorecard').change(function() {
      var linkElement = $('#initiative-detail-scorecard-link');
      var newLinkId = $('.initiative-detail-scorecard').first().val();
      
      linkElement.attr('href', "/scorecards/" + newLinkId);
    });
  });
  
  var ensureOrgEditControl = function (createOrgButton) {
    var availableOrgEditControl = createOrgButton.parent().parent().find(".select [name*='[organisation_id]']").filter(function(){ 
      return ($(this).val() == '') && $(this).is(':visible')
    });

    if (availableOrgEditControl.length == 0) {
      createOrgButton.trigger('click');
    }
  } 
  
  $(document).ready(function() {
    $('.assign-another-organisation').each(function() {
      ensureOrgEditControl($(this));
    });
    
    $('.assign-organisation-select').change(function() {
      ensureOrgEditControl($('.assign-another-organisation'));
    });
  });
  // *** Create Scorecard Wizard - General - Datepickers
  
  $(document).ready(function() {
    $('[data-behaviour~=datepicker]').datepicker({
    "format": "yyyy-mm-dd",
    "weekStart": 1,
    "autoclose": true
    });
  });
  


  $(document).ready(function() {
    $(document).on("fields_added.nested_form_fields", function(event, param) {
      switch (param.object_class) {
        case "initiative":
          $('[data-behaviour~=datepicker]').datepicker({
            "format": "yyyy-mm-dd",
            "weekStart": 1,
            "autoclose": true
          });
          var createAdditionalOrganisationButton = $(event.target).find('.assign-another-organisation');
          ensureOrgEditControl(createAdditionalOrganisationButton);
        case "initiatives_organisation":
          var selectControl = $(event.target).find("select[name*='organisation_id']")
          var createAdditionalOrganisationButton = $(event.target).parent().parent().find('.assign-another-organisation');
          selectControl.change(function() {
            ensureOrgEditControl(createAdditionalOrganisationButton);
          });
        
          return true;  
        default:
          return console.log(param.object_class);
      }
    });
  });
  
  
  // *** Create Scorecard Wizard - Initiatives
  
  
  // *** Dodgey way of effecting the creation of new controls for the next organisation record
  // $(document).ready(function() {
  //   $('.scorecard_initiatives_initiatives_organisations_organisation_id > div > select').change(function() {
  //     ensureOrgEditControl($('.assign-another-organisation'));
  //   });
  // });
  
  $(document).ready(function() {
    $(document).on("fields_removed.nested_form_fields", function(event, param) {
      switch (param.object_class) {
        case "initiatives_organisation":
          createAdditionalOrganisationButton = $(event.target).parent().parent().find('.assign-another-organisation');
          selectControls = $(event.target).find("select[name*='organisation_id']")
          ensureOrgEditControl(createAdditionalOrganisationButton);
          return true;  
        default:
          return console.log(param.object_class);
      }
    });
  });
  
  
  // *** Create Scorecard Wizard - Preview
  
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
            if ($("input[name*='scorecard[initiatives_attributes][" + index + "][_destroy]'").length != 0) { 
              return true;
            } else {
              if ($(value).val() === "") {
                $('ul#preview-initiatives').append('<li><em style="color:red">Name missing</em></li>');
              } else {
                $('ul#preview-initiatives').append('<li>'+$(value).val()+'</li>');
              }
            }
          });
        }
      }
    });
  });

  // *** Dashboard
  
  $(document).ready(function() {
     $('.video-tutorial-wrapper').on('click', function(e) {
       var link = $(this).data('video-tutorial-link');
       $('.modal').find(".modal-content").load(link);
       $('.modal').modal('show');
       e.preventDefault();
     });
  });
  
  $(document).ready(function() {
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
      
      var params = {
        selected_date: picker.startDate.format('YYYY-MM-DD')
      };
      
      var url = '/scorecards/' + scorecardId + '?' + $.param(params);
      $(location).attr('href', url)
    });
  });
  
  $(document).ready(function() {
    $('.download').bind('click', function(e) {
      e.preventDefault();
    });
  });
  
  //= require scorecards
  //= require turbolinks
  //= require_tree .