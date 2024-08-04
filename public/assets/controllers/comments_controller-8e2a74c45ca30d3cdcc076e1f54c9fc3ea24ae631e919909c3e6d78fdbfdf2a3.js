// import Rails from "@rails/ujs";
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "characteristic", "checklistItem", "currentComment", "newComment", "missingStatusAlert", "missingCommentAlert", "badge"]

  open(event) {
    event.preventDefault()

    $("[data-toggle='tooltip']").tooltip('hide');

    let loadPath = this.element.dataset.loadPath;

    let formTarget = this.formTarget;
    $(formTarget).show();

    Rails.ajax({
      type: "get",
      url: loadPath,
      success: function(data) { formTarget.innerHTML = data.body.innerHTML },
      error: function(data) { alert('Error') }
    })
  }

  close(event) {
    event.preventDefault()
    $(this.formTarget).hide()
  }

  onPostSuccess(event) {
    $(this.formTarget).hide()

    let statePath = this.element.dataset.statePath;
    let characteristicTarget = $(this.characteristicTarget)
    let badgeTarget = $(this.badgeTarget)
    let allStatusClasses = ['actual', 'planned', 'suggestion', 'more-information', 'no-comment']

    Rails.ajax({
      type: "get",
      url: statePath,
      success: function(data) {
        var status =  data.status.replace('_', '-')

        characteristicTarget.removeClass(allStatusClasses)
        characteristicTarget.addClass(status)

        badgeTarget.removeClass(allStatusClasses)
        badgeTarget.addClass(status)

        badgeTarget.removeClass(['fa-square-o', 'fa-square'])

        if (status == 'no-comment') {
          badgeTarget.addClass('fa-square-o')
        } else {
          badgeTarget.addClass('fa-square')
        }

        $(badgeTarget).attr('data-original-title', data.humanized_status)
       },
      error: function(data) { alert('Error') }
    })
  }
};
