
import Rails from "@rails/ujs";
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "activities", "targetsNetworkMap" ]

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

  loadTargetsNetworkMap(event) {
    event.preventDefault()

    let loadPath = window.location.pathname + '/targets_network_map.json';

    debugger

    Rails.ajax({
      type: "get",
      url: loadPath,
      success: function(data) { activitiesTarget.innerHTML = data.body.getInnerHTML() },
      error: function(data) { alert('Error') }
    })
  }
}
