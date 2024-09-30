import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "previewName", "previewColor", "nameField", "colorField", "submitButton"]

  checkFields(element) {
    const nameField = element.currentTarget.closest("form").querySelector("[data-labels-target='nameField']")
    const colorField = element.currentTarget.closest("form").querySelector("[data-labels-target='colorField']")
    const submitButton = element.currentTarget.closest("form").querySelector("[data-labels-target='submitButton']")

    const nameValue = nameField.value.trim()
    const colorValue = colorField.value.trim()
    const isFormValid = nameValue !== "" && colorValue !== ""

    submitButton.disabled = !isFormValid
    submitButton.classList.toggle("opacity-50", !isFormValid)
    submitButton.classList.toggle("cursor-not-allowed", !isFormValid)
  }

  toggle(event) {
    const newForm = document.querySelector('#new_label_form > form')

    if (newForm === null) {
      // console.log("newForm is null")
    } else {
      if (newForm.classList.contains("hidden")) {
        newForm.classList.remove("hidden")
      } else {
        newForm.classList.add("hidden")
      }
      event.preventDefault()
    }
  }

  updatePreviewName(element) {
    const value = element.currentTarget.value
    const previewNameElement = element.currentTarget.closest("form").querySelector("[data-labels-target='previewName']")

    previewNameElement.innerText  = value.trim() === "" ? "Preview" : value

    this.checkFields(element)
  }

  updatePreviewColor(element) {
    const value = element.currentTarget.value
    const previewColorElement = element.currentTarget.closest("form").querySelector("[data-labels-target='previewColor']")

    previewColorElement.style.color = value
    previewColorElement.style.borderColor = value
    previewColorElement.style.backgroundColor = `oklch(from ${value} l c h / 0.1)`;
  }

  focusNameField() {
    if (!this.formTarget.classList.contains("hidden")) {
      this.nameFieldTarget.focus()
    }
  }
}
