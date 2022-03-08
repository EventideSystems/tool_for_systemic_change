
import Rails from "@rails/ujs";
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "activities" ]

  loadActivities(event) {
    event.preventDefault()

    let activitiesTarget = this.activitiesTarget;
    let loadPath = window.location.pathname + '/activities';

    Rails.ajax({
      type: "get",
      url: loadPath,
      success: function(data) { activitiesTarget.innerHTML = data.body.getInnerHTML() },
      error: function(data) { alert('Error') }
    })
  }
}
