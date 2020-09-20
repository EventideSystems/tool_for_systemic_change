import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "toggleLabels", "toggleLegend" ]

  toggleLabels(event) {
    event.preventDefault()
  
    const visible = this.toggleLabelsTarget.classList.toggle("active")
    $('svg g.texts text').attr('visibility', function (node) { 
      if (visible) { return 'visible' } else { return 'hidden' }
    })  
  }

  toggleLegend(event) {
    event.preventDefault()
  
    const visible = this.toggleLegendTarget.classList.toggle("active")
    if (visible) {
      $('#ecosystem-maps .legend').show()
    } else {
      $('#ecosystem-maps .legend').hide()
    } 
  }
}
