/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

require('turbolinks').start()
// require('@rails/activestorage').start()
// require('channels')
require('file-loader')
require('d3')
require('bootstrap')
require('admin-lte')
require('medium-editor')
require('twitter-bootstrap-wizard')
require('select2')
require('bootstrap-nav-wizard')
require('bootstrap-daterangepicker')

import $ from 'jquery';
global.$ = jQuery;

window.moment = require('moment');

import * as bootstrap from 'bootstrap';

import * as d3 from "d3";
window.d3 = d3;

import * as AdminLTE from 'admin-lte/dist/js/adminlte';

import 'bootstrap-datepicker/dist/js/bootstrap-datepicker';

// import 'medium-editor';

$(document).on('turbolinks:load', function() {
  var o;
  o = AdminLTE.options;
  if (o.sidebarPushMenu) {
    AdminLTE.pushMenu.activate(o.sidebarToggleSelector);
  }
  return AdminLTE.layout.activate();
});

// $( document ).ready(function() {
//   var editor = new MediumEditor('.textarea', {buttonLabels: 'bootstrap'});
// });

$(document).on('turbolinks:load', function() {
  $(".select2").select2();
});

$(document).on('turbolinks:load', function() {
  $(document).on('click', '.organisation-link', function() {
    $(this).parent().parent().find('select').attr('current', true);
  });
});

$(document).on('turbolinks:load', function() {
  $(document).on('click', '.subsystem-tag-link', function() {
    $(this).parent().parent().find('select').attr('current', true);
  });
});
  
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
    var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
    $(commentFormId).toggle();
    event.preventDefault();
  });
});

$(document).on('turbolinks:load', function() {
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

$(document).on('turbolinks:load', function() {
  $(document).on('click', '.btn-checklist-comment-cancel', function(event) {
    var commentFormId = '#characteristic-comment-form-' + $(this).data('id');
    $(commentFormId).toggle();
    event.preventDefault();
  });
});


$(document).on('turbolinks:load', function() {
  $(document).on('click', '.show-gaps-button', function() {
    $('.cell').toggleClass('inverse');
  });
});

$(document).on('turbolinks:load', function() {
  $('a.link-disabled').click(function(event){
    event.preventDefault(); // Prevent link from following its href
  });
});

$(document).on('turbolinks:load', function() {
   $('.remote-link').on('click', function(e) {
     var link = $(this).attr('href');
     $('.modal').find(".modal-content").load(link);
     $('.modal').modal('show');
     e.preventDefault();
   });
});

$(document).on('turbolinks:load', function() {
  $('body').on('hidden.bs.modal', '.modal', function () {
    $(this).find('iframe').removeAttr('src');
  });
});

$(document).on('turbolinks:load', function() {
  $('.initiative-detail-scorecard').change(function() {
    var linkElement = $('#initiative-detail-scorecard-link');
    var newLinkId = $('.initiative-detail-scorecard').first().val();
    
    linkElement.attr('href', "/transition_cards/" + newLinkId);
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

var ensureSubsystemTagEditControl = function (createSubsystemTagButton) {
  var availableSubsystemTagEditControl = createSubsystemTagButton.parent().parent().find(".select [name*='[subsystem_tag_id]']").filter(function(){ 
    return ($(this).val() == '') && $(this).is(':visible')
  });

  if (availableSubsystemTagEditControl.length == 0) {
    createSubsystemTagButton.trigger('click');
  }
}

$(document).on('turbolinks:load', function() {
  $('.assign-another-organisation').each(function() {
    ensureOrgEditControl($(this));
  });
  
  $('.assign-organisation-select').change(function() {
    ensureOrgEditControl($('.assign-another-organisation'));
  });
  
  $('.assign-another-subsystem-tag').each(function() {
    ensureSubsystemTagEditControl($(this));
  });
  
  $('.assign-subsystem-tag-select').change(function() {
    ensureSubsystemTagEditControl($('.assign-another-subsystem-tag'));
  });
  
});
// *** Create Scorecard Wizard - General - Datepickers

$(document).on('turbolinks:load', function() {

  $('[data-behaviour~=datepicker]').datepicker({
    "format": "yyyy-mm-dd",
    "weekStart": 1,
    "autoclose": true
  });
  
  $('[data-behaviour~=datepicker-auto-bottom]').datepicker({
    "format": "yyyy-mm-dd",
    "weekStart": 1,
    "autoclose": true,
    "orientation": 'auto bottom'
  });
});

$(document).on('turbolinks:load', function() {
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
        var createAdditionalSubsystemTagButton = $(event.target).find('.assign-another-subsystem-tag');
        ensureSubsystemTagEditControl(createAdditionalSubsystemTagButton);
      case "initiatives_organisation":
        var selectControl = $(event.target).find("select[name*='organisation_id']")
        var createAdditionalOrganisationButton = $(event.target).parent().parent().find('.assign-another-organisation');
        selectControl.change(function() {
          ensureOrgEditControl(createAdditionalOrganisationButton);
        });
      
        return true;
      case "initiatives_subsystem_tag":
        var selectControl = $(event.target).find("select[name*='subsystem_tag_id']")
        var createAdditionalSubsystemTagButton = $(event.target).parent().parent().find('.assign-another-subsystem-tag');
        selectControl.change(function() {
          ensureSubsystemTagEditControl(createAdditionalSubsystemTagButton);
        });
      
        return true;
      default:
        return console.log(param.object_class);
    }
  });
});


// *** Create Scorecard Wizard - Initiatives


// *** Dodgey way of effecting the creation of new controls for the next organisation record
// $(document).on('turbolinks:load', function() {
//   $('.scorecard_initiatives_initiatives_organisations_organisation_id > div > select').change(function() {
//     ensureOrgEditControl($('.assign-another-organisation'));
//   });
// });

$(document).on('turbolinks:load', function() {
  $(document).on("fields_removed.nested_form_fields", function(event, param) {
    switch (param.object_class) {
      case "initiatives_organisation":
        createAdditionalOrganisationButton = $(event.target).parent().parent().find('.assign-another-organisation');
        selectControls = $(event.target).find("select[name*='organisation_id']")
        ensureOrgEditControl(createAdditionalOrganisationButton);
        return true;
      case "initiatives_subsystem_tag":
        createAdditionalSubsystemTagButton = $(event.target).parent().parent().find('.assign-another-subsystem-tag');
        selectControls = $(event.target).find("select[name*='subsystem_tag_id']")
        ensureSubsystemTagEditControl(createAdditionalSubsystemTagButton);
        return true;  
      default:
        return console.log(param.object_class);
    }
  });
});


// *** Create Scorecard Wizard - Preview

$(document).on('turbolinks:load', function() {
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

$(document).on('turbolinks:load', function() {
   $('.video-tutorial-wrapper').on('click', function(e) {
     var link = $(this).data('video-tutorial-link');
     $('.modal').find(".modal-content").load(link);
     $('.modal').modal('show');
     e.preventDefault();
   });
});

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

$(document).on('turbolinks:load', function() {
  $('.download').bind('click', function(e) {
    e.preventDefault();
  });
});


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
    var scorecardId = $(e.target).data('scorecard-id');
    var tags = $.map($('#subsystem-tags').select2('data'), function(v) { return v.text });
    var date = $('#daterange-btn').data('selectedDate');
    var params = { selected_tags: tags, selected_date: date };

    var url = '/transition_cards/' + scorecardId + '?' + $.param(params);
    $(location).attr('href', url)
  });
  
  $("#subsystem-tags").on("change", function(e) { 
    $('.select2-selection__choice:not(.selected-subsystem-tag)', this).addClass('selected-subsystem-tag');
  });
});
