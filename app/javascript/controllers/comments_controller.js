import Rails from "@rails/ujs";
import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["form", "characteristic", "checklistItem", "currentComment", "newComment", "missingStatusAlert", "missingCommentAlert"]

  open(event) {
    event.preventDefault()

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
    let checklistItemTarget = $(this.checklistItemTarget)

    Rails.ajax({
      type: "get",
      url: statePath,
      success: function(data) {
        characteristicTarget.removeClass('actual')
        characteristicTarget.removeClass('planned')
        characteristicTarget.removeClass('suggestion')
        characteristicTarget.removeClass('more_information')

        characteristicTarget.addClass( data.comment_status )
        checklistItemTarget.prop('checked', data.checked)
       },
      error: function(data) { alert('Error') }
    })
  }

  // SMELL: Never called
  onPostUpdateCommentError(event) {
    event.preventDefault()
  }

  onPostNewCommentError(event) {
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
