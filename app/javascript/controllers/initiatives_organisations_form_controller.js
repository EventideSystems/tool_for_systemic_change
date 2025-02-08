import { Controller } from "@hotwired/stimulus"

// NOTE: This is very similar to initiatives_subsystem_tags_controller.js and can probably be refactored
// to remove the duplication
export default class extends Controller {
  static targets = ["form", "nameField", "submitButton"]

  connect() {
    this.checkFields({ currentTarget: this.nameFieldTarget })
  }

  checkFields(element) {
    const submitButton = this.submitButtonTarget

    const nameValue = this.nameFieldTarget.value.trim()
    const isFormValid = nameValue !== ""

    submitButton.disabled = !isFormValid
    submitButton.classList.toggle("opacity-50", !isFormValid)
    submitButton.classList.toggle("cursor-not-allowed", !isFormValid)
  }
  
}