import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["filterForm", "date", "subsystemTags", "statuses", "grid"]

  connect() {
    this.dateTarget.addEventListener("change", this.submitForm.bind(this))
    this.subsystemTagsTarget.addEventListener("change", this.submitForm.bind(this))
    this.statusesTarget.addEventListener("change", this.updateStatuses.bind(this))
    this.updateStatuses({ target: this.statusesTarget })
  }

  submitForm() {
    this.filterFormTarget.requestSubmit()
  }

  updateStatuses(event) {
    const selected = event.target.selectedOptions
    const statuses = Array.from(selected).map(({ value }) => value)

    const url = new URL(window.location)
    url.searchParams.delete('statuses[]')

    if (statuses && statuses.length > 0) {
      statuses.forEach(status => {
        url.searchParams.append('statuses[]', status)
      })
    }

    window.history.replaceState({}, '', url)

    const elements = this.gridTarget.querySelectorAll('[data-status]')

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
