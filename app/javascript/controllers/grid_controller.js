import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "filterForm", "date", "subsystemTags", "statuses", "grid",
    "selectedSubsystemTagsForPrint",
    "selectedStatusesForPrint",
    "selectedSubsystemTagsForPrintContainer",
    "selectedStatusesForPrintContainer",
    "selectedDisplayingGap",
    "highlightButton"
  ]

  connect() {
    this.dateTarget.addEventListener("change", this.submitForm.bind(this))
    this.subsystemTagsTarget.addEventListener("change", this.updateSubsystemTags.bind(this))
    this.statusesTarget.addEventListener("change", this.updateStatuses.bind(this))
    this.highlightButtonTarget.addEventListener("click", this.toggleHighlight.bind(this))

    this.updateStatuses({ target: this.statusesTarget })
    this.updateSubsystemTags({ target: this.subsystemTagsTarget })
    this.updateHighlightButtonIcon()
  }

  submitForm() {
    this.filterFormTarget.requestSubmit()
  }

  updateHighlightButtonIcon() {
    const url = new URL(window.location)
    const highlightSet = url.searchParams.get('highlight') == 'true'
    const svg = this.highlightButtonTarget.querySelector('svg')
    const filterSection = this.selectedDisplayingGapTarget

    if (highlightSet) {
      svg.classList.add('icon-highlight')

      filterSection.classList.add('print:block')
      filterSection.classList.remove('print:hidden')
    } else {
      svg.classList.remove('icon-highlight')

      filterSection.classList.remove('print:block')
      filterSection.classList.add('print:hidden')
    }
  }

  toggleHighlight(event) {
    event.preventDefault()
    const url = new URL(window.location)
    const highlightSet = url.searchParams.get('highlight') == 'true'
    url.searchParams.set('highlight', !highlightSet)
    window.history.replaceState({}, '', url)

    this.updateStatuses({ target: this.statusesTarget })
    this.updateHighlightButtonIcon()
  }

  updateSubsystemTags(event) {
    const selected = event.target.selectedOptions
    const subsystemTags = Array.from(selected).map(({ value }) => value)

    const url = new URL(window.location)
    url.searchParams.delete('subsystem_tags[]')

    this.selectedSubsystemTagsForPrintTarget.innerHTML = ''

    if (subsystemTags && subsystemTags.length > 0) {

      this.selectedSubsystemTagsForPrintContainerTarget.classList.add('print:block')
      subsystemTags.forEach(tag => {

        this.selectedSubsystemTagsForPrintTarget.innerHTML +=
          `<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-zinc-500 text-white" >${tag}</span>`

        url.searchParams.append('subsystem_tags[]', tag)
      })
    } else {
      this.selectedSubsystemTagsForPrintContainerTarget.classList.remove('print:block')
    }

    window.history.replaceState({}, '', url)

    const elements = this.gridTarget.querySelectorAll('[data-subsystem-tags]')

    elements.forEach(element => {
      const tags = JSON.parse(element.getAttribute('data-subsystem-tags'))

      const visible = subsystemTags === undefined || subsystemTags.length == 0 || subsystemTags.some(tag => tags.includes(tag))

      if (visible) {
        element.parentNode.classList.remove('invisible')
        element.parentNode.nextElementSibling.classList.remove('invisible')

        element.parentNode.classList.remove('h-0')
        element.parentNode.nextElementSibling.classList.remove('h-0')

        element.parentNode.classList.remove('mb-0')
        element.parentNode.nextElementSibling.classList.remove('mb-0')

        element.parentNode.classList.add('mb-2')
        element.parentNode.nextElementSibling.classList.add('mb-2')

      } else {
        element.parentNode.classList.add('invisible')
        element.parentNode.nextElementSibling.classList.add('invisible')

        element.parentNode.classList.add('h-0')
        element.parentNode.nextElementSibling.classList.add('h-0')

        element.parentNode.classList.add('mb-0')
        element.parentNode.nextElementSibling.classList.add('mb-0')

        element.parentNode.classList.remove('mb-2')
        element.parentNode.nextElementSibling.classList.remove('mb-2')
      }
    })
  }

  updateStatuses(event) {
    const selected = event.target.selectedOptions
    const statuses = Array.from(selected).map(({ value }) => value)

    const url = new URL(window.location)
    url.searchParams.delete('statuses[]')

    this.selectedStatusesForPrintTarget.innerHTML = ''

    if (statuses && statuses.length > 0) {
      this.selectedStatusesForPrintContainerTarget.classList.add('print:block')

      statuses.forEach(status => {
        const capitalizedStatus = status
          .replace(/_/g, ' ') // Replace underscores with spaces
          .replace(/\b\w/g, char => char.toUpperCase()); // Capitalize the first letter of each word

        const statusName = status.charAt(0).toUpperCase() + status.slice(1)
        this.selectedStatusesForPrintTarget.innerHTML +=
          `<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-zinc-500 text-white" >${capitalizedStatus}</span>`
        url.searchParams.append('statuses[]', status)
      })
    } else {
      this.selectedStatusesForPrintContainerTarget.classList.remove('print:block')
    }

    window.history.replaceState({}, '', url)

    const elements = this.gridTarget.querySelectorAll('[data-status]')
    const highlightSet = url.searchParams.get('highlight') == 'true'

    elements.forEach(element => {
      const status = element.getAttribute('data-status')
      const elementClass = element.getAttribute('data-element-class')

      element.classList.remove('status-highlight')
      element.classList.remove('status-no-comment')
      element.classList.remove(elementClass)

      if (statuses === undefined || statuses.length == 0 || statuses.includes(status)) {
        if (highlightSet) {
          if (status == 'no_comment') {
            element.classList.add('status-highlight')
          } else {
            element.classList.add('status-no-comment')
          }
        } else {
          element.classList.add(elementClass)
        }
      } else {
        if (highlightSet) {
          element.classList.add('status-highlight')
        } else {
          element.classList.add('status-no-comment')
        }
      }
    })
  }
}
