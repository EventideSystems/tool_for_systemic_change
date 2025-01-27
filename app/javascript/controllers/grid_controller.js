import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "filterForm", "date", "subsystemTags", "statuses", "grid",
    "selectedSubsystemTagsForPrint",
    "selectedStatusesForPrint",
    "selectedSubsystemTagsForPrintContainer",
    "selectedStatusesForPrintContainer"
  ]

  connect() {
    this.dateTarget.addEventListener("change", this.submitForm.bind(this))
    this.subsystemTagsTarget.addEventListener("change", this.updateSubsystemTags.bind(this))
    this.statusesTarget.addEventListener("change", this.updateStatuses.bind(this))
    this.updateStatuses({ target: this.statusesTarget })
    this.updateSubsystemTags({ target: this.subsystemTagsTarget })
  }

  submitForm() {
    this.filterFormTarget.requestSubmit()
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

    if (this.data.get('mode') == 'classic') {
      elements.forEach(element => {
        const status = element.getAttribute('data-status')
        const baseColor = element.getAttribute('data-focus-area-color')
        const opacity = this.statusBackgroundColorOpacity(status)
        const color = `${baseColor}${opacity}`

        if (statuses === undefined || statuses.length == 0 || statuses.includes(status)) {
          element.style.backgroundColor = color
        } else {
          element.style.backgroundColor = '#00000000'
        }
      })
    } else {
      elements.forEach(element => {
        const status = element.getAttribute('data-status')
        const colorClasses = this.statusColorClasses(status)

        if (statuses === undefined || statuses.length == 0 || statuses.includes(status)) {
          element.classList.add(...colorClasses)
          element.classList.remove('bg-gray-500')
        } else {
          element.classList.remove(...colorClasses)
          element.classList.add('bg-gray-500')
        }
      })
    }
  }


  // NOTE: Duplicated in checklist_items_helper.rb
  statusBackgroundColorOpacity(status) {
    switch (status) {
      case 'actual':
        return 'FF'
      case 'planned':
        return '99'
      case 'more_information':
        return '66'
      case 'suggestion':
        return '40'
      default:
        return '00'
    }
  }

  statusColorClasses(status) {
    switch (status) {
      case 'actual':
        return ['bg-sky-600']
      case 'planned':
        return ['bg-teal-500']
      case 'more_information':
        return ['bg-yellow-400']
      case 'suggestion':
        return ['bg-indigo-400']
      default:
        return ['bg-gray-200', 'dark:bg-gray-600']
    }
  }
}
