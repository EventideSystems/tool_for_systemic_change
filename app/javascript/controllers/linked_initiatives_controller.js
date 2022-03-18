import Rails from "@rails/ujs";
import { Controller } from "stimulus";

export default class extends Controller {

  static targets = [ "initiativesList", "selectLinkedScorecard" ]

  changeLinkedScorecard(event) {
    event.preventDefault()

    let loadPath = window.location.pathname + '/linked_initiatives/' + $(event.target).val();
    let initiativesListTarget = this.initiativesListTarget;

    Rails.ajax({
      type: "get",
      url: loadPath,
      success: function(data) { initiativesListTarget.innerHTML = data.body.getInnerHTML() },
      error: function(data) { alert('Error') }
    })
  }
}
