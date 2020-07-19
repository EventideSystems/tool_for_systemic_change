import * as smartwizard from "smartwizard";
window.smartwizard = smartwizard;

$(document).on('turbolinks:load', function() {
  $('.wizard').smartWizard({
    theme: 'arrows',
    anchorSettings: { 
      enableAllAnchors: true,
      justified: true,
      autoAdjustHeight: true,
      markDoneStep: false
    }
  });
});

// Initiatives

$(document).on('turbolinks:load', function() {
  $('#initiatives').on('cocoon:after-insert', function() {
    $(".tab-content").css("height", "auto");
  });
});

// Preview

$(document).on('turbolinks:load', function() {

  $('.wizard').on("showStep", function(e, a1, a2, a3, stepPosition) {
    
    if (stepPosition == 'last') {
      
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
  });
});
