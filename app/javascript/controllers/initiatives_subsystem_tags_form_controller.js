import LabelsController from "controllers/labels_controller";

export default class InitiativesSubsystemTagsFormController extends LabelsController {
 
  static targets = ["form", "nameField", "colorField", "submitButton", "nameError"]
  static values = { subsystemTags: Array }

  checkFields(element) {
    const nameField = this.nameFieldTarget
    const colorField = this.colorFieldTarget
    const submitButton = this.submitButtonTarget

    const nameValue = nameField.value.trim()
    const colorValue = colorField.value.trim()
    var isFormValid = nameValue !== "" && colorValue !== ""

    if (isFormValid) {
      const subsystemTags = this.subsystemTagsValue.map(name => name.toLowerCase())
      const isNameValid = !subsystemTags.includes(nameValue.toLowerCase())

      if (!isNameValid) {
        this.nameErrorTarget.textContent = "Subsystem tag with this name already exists"
        isFormValid = false
      } else {
        this.nameErrorTarget.textContent = ""
      }
    }

    submitButton.disabled = !isFormValid
    submitButton.classList.toggle("opacity-50", !isFormValid)
    submitButton.classList.toggle("cursor-not-allowed", !isFormValid)
  }
}