import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["initiativesSubsystemTags"]

  connect() {
    this.index = this.initiativesSubsystemTagsTarget.children.length
  }

  addTag(event) {
    event.preventDefault()
    const template = document.getElementById("subsystem_tag_template")
    const clone = template.content.cloneNode(true)

    clone.querySelectorAll("select").forEach((input) => {
      input.name = input.name.replace(/__INDEX__/g, this.index)
      input.id = input.id.replace(/__INDEX__/g, this.index)
    })

    this.initiativesSubsystemTagsTarget.appendChild(clone)

    this.index++
  }

  removeTag(event) {
    event.preventDefault()
    event.target.closest('.flex').remove()
  }
}
