import Rails from "@rails/ujs";
import { Controller } from "stimulus";

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
      success: function(data) { formTarget.innerHTML = data.body.getInnerHTML() },
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

    Rails.ajax({
      type: "get",
      url: statePath,
      success: function(data) {
        characteristicTarget.removeClass('actual')
        characteristicTarget.removeClass('planned')
        characteristicTarget.removeClass('suggestion')
        characteristicTarget.removeClass('more-information')
        characteristicTarget.addClass( data.status.replace('_', '-') )

        badgeTarget.removeClass('no-comment')
        badgeTarget.removeClass('actual')
        badgeTarget.removeClass('planned')
        badgeTarget.removeClass('suggestion')
        badgeTarget.removeClass('more-information')
        badgeTarget.addClass( data.status.replace('_', '-') )

        $(badgeTarget).attr('data-original-title', data.humanized_status)
       },
      error: function(data) { alert('Error') }
    })
  }

  onPostError(event) {
    event.preventDefault()

    $(this.missingStatusAlertTarget).show()

    let [data, status, xhr] = event.detail;

    if (data.errors.includes("Status can't be blank")) {
      $(this.missingStatusAlertTarget).show()
    } else {
      $(this.missingStatusAlertTarget).hide()
    }

    if (data.errors.includes("Comment can't be blank")) {
      $(this.missingCommentAlertTarget).show()
    } else {
      $(this.missingCommentAlertTarget).hide()
    }
  }

}
