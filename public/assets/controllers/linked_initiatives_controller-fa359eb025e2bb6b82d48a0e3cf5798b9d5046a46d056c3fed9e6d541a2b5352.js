// import Rails from "@rails/ujs";
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [ "initiativesList", "selectLinkedScorecard" ]

  changeLinkedScorecard(event) {
    event.preventDefault()

    let initiativesListTarget = this.initiativesListTarget

    if ($(event.target).val() == '') {
      initiativesListTarget.innerHTML = ''
    } else {
      let loadPath = window.location.pathname + '/linked_initiatives/' + $(event.target).val()

      Rails.ajax({
        type: "get",
        url: loadPath,
        success: function(data) { initiativesListTarget.innerHTML = data.body.getInnerHTML() },
        error: function(data) { alert('Error') }
      })
    }
  }

  updateAll(event) {
    $('.linked-initiative').prop('checked', event.target.checked)
  }
};
