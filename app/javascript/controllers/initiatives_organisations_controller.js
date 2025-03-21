import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["initiativesOrganisations"]
  
  connect() {
    this.index = this.initiativesOrganisationsTarget.children.length
  }

  // TODO: Rename to 'addStakeholder' and 'removeStakeholder'
  addTag(event) {
    event.preventDefault()
    const template = document.getElementById("organisation_template")
    const clone = template.content.cloneNode(true)

    clone.querySelectorAll("select").forEach((input) => {
      input.name = input.name.replace(/__INDEX__/g, this.index)
      input.id = input.id.replace(/__INDEX__/g, this.index)
    })

    this.initiativesOrganisationsTarget.appendChild(clone)
    this.index++
  }

  removeTag(event) {
    event.preventDefault()
    event.target.closest('.flex').remove()
  }
}
