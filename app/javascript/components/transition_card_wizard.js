import * as smartwizard from "smartwizard";
window.smartwizard = smartwizard;

$(document).on('turbolinks:load', function() {
  $('.wizard').smartWizard({
    theme: 'arrows',
    anchorSettings: {
      enableAllAnchors: true,
      justified: true,
      autoAdjustHeight: false,
      markDoneStep: false,
    },
    keyboardSettings: {
      keyNavigation: false
    },
    lang: {
      next: 'Next \u203A',
      previous: '\u2039 Previous'
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

  $('.wizard').on("leaveStep", function(e, a1, a2, a3, stepPosition) {

    var scorecard_name = $('#transition_card_name').val();
    var scorecard_desc = $('#transition_card_description').val();

    if (scorecard_name === "") {
      scorecard_name = '<em style="color:red">Missing</em>'
    }

    $("#preview-transition_card-name").html(scorecard_name);
    $("#preview-transition_card-description").html(scorecard_desc);

    var wicked_problem_name = $("[data='wicked_problem_selector'] option:selected").text();
    var wicked_problem_id = $("[data='wicked_problem_selector']").val();

    if (wicked_problem_name === "") {
      wicked_problem_name = '<em style="color:red">Missing</em>'
    }

    $("#preview-wicked-problem-name").html(wicked_problem_name);
    if (wicked_problem_id) {
      fetchWickedProblemDescription(wicked_problem_id);
    }

    var community_name = $("[data='community_selector'] option:selected").text();
    var community_id = $("[data='community_selector']").val();

    if (community_name === "") {
      community_name = '<em style="color:red">Missing</em>'
    }

    $("#preview-community-name").html(community_name);
    if (community_id) {
      fetchCommunityDescription(community_id);
    }

    $('ul#preview-initiatives li').remove()
    $('.initiative-name').each(function (index, value) {
      if ($("input[name*='transition_card[initiatives_attributes][" + index + "][_destroy]'").length != 0) {
        return true;
      } else {
        if ($(value).val() === "") {
          $('ul#preview-initiatives').append('<li><em style="color:red">Name missing</em></li>');
        } else {
          $('ul#preview-initiatives').append('<li>'+$(value).val()+'</li>');
        }
      }
    });
  });
});
