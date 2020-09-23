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

  zoomIn(event) {
    event.preventDefault()

    let svg = d3.select(this.activeChartSvgSelector)
    let zoom = d3.zoom().on("zoom", function () {
      svg.attr("transform", d3.event.transform)
    })
    
    zoom.scaleBy(svg.transition().duration(750), 1.2)
  }

  zoomOut(event) {
    event.preventDefault()
    
    let svg = d3.select(this.activeChartSvgSelector)
    let zoom = d3.zoom().on("zoom", function () {
      svg.attr("transform", d3.event.transform)
    })
    zoom.scaleBy(svg.transition().duration(750), 0.8)
  }

  zoomReset(event) {
    event.preventDefault()

    let svg = d3.select(this.activeChartSvgSelector)
    var transform = d3.zoomIdentity.translate(0, 0).scale(1)
    let zoom = d3.zoom().on("zoom", function () {
      svg.attr("transform", d3.event.transform)
    })
    svg.call(zoom.transform, transform)
  }

  get activeChartId() {
    return '#' + $('#ecosystem-maps .tab-content .tab-pane.active .chart').attr('id')
  }

  get activeChartSvgSelector() {
    return this.activeChartId + ' > svg'
  }

}
