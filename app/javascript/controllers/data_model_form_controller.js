import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["dangerZone", "dangerZoneButton"]

  showDangerZone(event) {
    event.preventDefault()

    this.dangerZoneButtonTarget.classList.toggle('hidden');
    this.dangerZoneTarget.classList.toggle('hidden');
  }
}