import { Controller } from "@hotwired/stimulus"
// import * as d3 from "d3"

export default class extends Controller {

  static targets = [
    "closeDialog",
    "dialog", 
    "dialogContent",
    "dialogTitle", 
    "dialogTitleColor", 
    "filterForm",
    "graph",
    "map",
    "toggleLabelsButton"
  ]

  connect() {
    window.addEventListener('beforeprint', this.beforePrint.bind(this));
    window.addEventListener('afterprint', this.afterPrint.bind(this));
  }

  disconnect() {
    window.removeEventListener('beforeprint', this.beforePrint.bind(this));
    window.removeEventListener('afterprint', this.afterPrint.bind(this));
  }

  afterPrint() {
    this.mapTarget.removeAttribute('height');
  }

  beforePrint() {
    const svg = this.mapTarget.querySelector('svg');
    const bounds = svg.getBBox();

    this.mapTarget.setAttribute('height', bounds.height + 100);
    svg.setAttribute('height', bounds.height + 100);
  }

  getLinkClass(link, node) {
    if (link.target.id === node.id || link.source.id === node.id) {
      return 'links stroke-green-300 dark:stroke-green-300'
    } else {
      return 'links stroke-zinc-400 dark:stroke-zinc-400'
    }
  }

  getNeighbors(links, node) {
    return links.reduce(function (neighbors, link) {
        if (link.target.id === node.id) {
          neighbors.push(link.source.id)
        } else if (link.source.id === node.id) {
          neighbors.push(link.target.id)
        }
        return neighbors
      },
      [node.id]
    )
  }

  getNodeColor(node, neighbors) {
    if (Array.isArray(neighbors) && neighbors.includes(node.id)) {
      return '#49C472'
    } else  {
      return node.color
    }
  }

  getTextClass(node, neighbors) {
    if (Array.isArray(neighbors) && neighbors.includes(node.id)) {
      return 'texts stroke-green-300 dark:stroke-green-300'
    } else {
      return 'texts stroke-zinc-400 dark:stroke-zinc-400'
    }
  }

  querySelectorIncludesText(selector, text) {
    return Array.from(document.querySelectorAll(selector))
      .find(el => el.textContent.includes(text));
  }

  toggleLabels(event) {
    if (typeof event.stopPropagation === 'function') {
      event.stopPropagation()
    }

    const url = new URL(window.location)
    const showLabels = url.searchParams.get('show_labels') == 'true'

    if (showLabels) {
      url.searchParams.delete('show_labels')
    } else {
      url.searchParams.append('show_labels', 'true')
    }

    window.history.replaceState({}, '', url)

    this.updateLabelsVisibility()
  }

  updateLabelsVisibility() {
    const textElements = this.mapTarget.querySelectorAll('.texts text')

    const url = new URL(window.location)
    const showLabels = url.searchParams.get('show_labels') == 'true'

    if (showLabels) {
      this.toggleLabelsButtonTarget.innerHTML = 'Hide names'

      textElements.forEach(element => {
        element.setAttribute('visibility', 'visible')
      })
    } else {
      this.toggleLabelsButtonTarget.innerHTML = 'Show names'

      textElements.forEach(element => {
        element.setAttribute('visibility', 'hidden')
      })
    }
  }
}