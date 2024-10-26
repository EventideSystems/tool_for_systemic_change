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

    previewColorElement.style.color = this.calculateLuminance(value) > 0.09 ? 'black' : '#e0e0e0'
    previewColorElement.style.backgroundColor = value;
  }

  focusNameField() {
    if (!this.formTarget.classList.contains("hidden")) {
      this.nameFieldTarget.focus()
    }
  }

  // Equivalent method in labels_helper.rb
  hexToRgb(hex) {
    hex = hex.replace('#', '');
    const r = parseInt(hex.substring(0, 2), 16);
    const g = parseInt(hex.substring(2, 4), 16);
    const b = parseInt(hex.substring(4, 6), 16);
    return [r, g, b];
  }

  // Equivalent method in labels_helper.rb
  calculateLuminance(hexColor) {
    let [r, g, b] = this.hexToRgb(hexColor);

    // Convert RGB to sRGB
    r = r / 255.0;
    g = g / 255.0;
    b = b / 255.0;

    // Apply gamma correction
    r = r <= 0.03928 ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4);
    g = g <= 0.03928 ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4);
    b = b <= 0.03928 ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4);

    // Calculate luminance
    const luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
    return luminance;
  }
}
