import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["date", "clear"]

  connect() {
    this.clearTarget.addEventListener("click", this.clearDate.bind(this))
  }

  clearDate() {
    this.dateTarget.value = ""
    this.dateTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
