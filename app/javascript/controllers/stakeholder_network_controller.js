import GraphController from "controllers/graph_controller";

// import { Controller } from "@hotwired/stimulus"
import * as d3 from "d3"

export default class extends GraphController  {

  static targets = [
    "stakeholderTypes", 
    "selectedStakeholderTypesForPrint", 
    "selectedStakeholderTypesForPrintContainer"
  ]

  connect() {
    super.connect()

    const data = this.getData()
    this.drawGraph(data)

    this.stakeholderTypesTarget.addEventListener("change", this.updateStakeholderTypes.bind(this))
    this.toggleLabelsButtonTarget.addEventListener("click", this.toggleLabels.bind(this))
    this.closeDialogTarget.addEventListener("click", () => this.dialogTarget.close())

    this.updateLabelsVisibility = this.updateLabelsVisibility.bind(this)
    this.updateStakeholderTypes = this.updateStakeholderTypes.bind(this)

    this.updateStakeholderTypes({ target: this.stakeholderTypesTarget })
    this.updateLabelsVisibility()
  }

  drawGraph(data) {
    const width = this.mapTarget.offsetWidth
    const height = this.mapTarget.offsetHeight

    let getNeighbors = this.getNeighbors
    let getLinkClass = this.getLinkClass
    let getNodeColor = this.getNodeColor
    let getTextClass = this.getTextClass

    let dialogTarget = this.dialogTarget
    let dialogTitleTarget = this.dialogTitleTarget
    let dialogTitleColorTarget = this.dialogTitleColorTarget
    let dialogContentTarget = this.dialogContentTarget

    let querySelectorIncludesText = this.querySelectorIncludesText.bind(this)
    let updateStakeholderTypes = this.updateStakeholderTypes.bind(this)

    let stakeholderTypesTarget = this.stakeholderTypesTarget

    let updateNodeColors = this.updateNodeColors.bind(this)

    var linkForce = d3
      .forceLink()
      .id(function (link) { return link.id })
      .strength(this.calcLinkStrength(data.links))

    var dragDrop = d3.drag()
      .on('start', function (event, node) {
        node.fx = node.x
        node.fy = node.y
      })
      .on('drag', function (event, node) {
        simulation.alphaTarget(0.1).restart()
        node.fx = event.x
        node.fy = event.y
      })
      .on('end', function (event, node) {
        if (!event.active) {
          simulation.alphaTarget(0)
        }
        node.fx = event.x
        node.fy = event.y
      })


    var simulation = d3
      .forceSimulation()
      .force('link', linkForce)
      .force('charge', d3.forceManyBody().strength(this.calcForceStrength(data.nodes, data.links)))
      .force('center', d3.forceCenter(width / 2.5, height / 3))

    const svg = d3.create("svg")
      .attr("width", width)
      .attr("height", height)
      .on('click', function(event) {
        if (event.target.tagName === 'svg') {
          linkElements.attr('class', function (link) { 'links stroke-zinc-400 dark:stroke-zinc-400' })
          textElements.attr('class', function() { 'texts stroke-zinc-400 dark:stroke-zinc-400' })

          const selected = stakeholderTypesTarget.selectedOptions
          const selectedStakeholderTypes = Array.from(selected).map(({ value }) => value)  

          updateNodeColors(selectedStakeholderTypes)
        }
      });

    var linkElements = svg.append("g")
      .attr("class", "links stroke-zinc-400 dark:stroke-zinc-400")
      .selectAll("line")
      .data(data.links)
      .enter().append("line")
        .attr("stroke-width", function(d) { return d.strength })

    var nodeElements = svg.append("g")
      .attr("class", "nodes")
      .selectAll("circle")
      .data(data.nodes)
      .enter().append("circle")
        .attr("r", 6)
        .attr("fill", this.getNodeColor)
        .call(dragDrop)
        .on('dblclick', function(event, node) {
          event.stopPropagation();

          dialogTitleTarget.innerHTML = node.label + ' - ' + node.stakeholderType
          dialogTitleColorTarget.style.backgroundColor = node.color

          const connections = data.links.filter(link => link.source.id == node.id || link.target.id == node.id)
          const connectionNames = connections.map(link => { return link.source.id == node.id ? link.target.label : link.source.label })
          const connectionNamesContent = connectionNames.map(name => {
            return `<li class="text-sm">${name}</li>`
          }).join('')

          const partneringInitiativesContent = node.partneringInitiatives.map(initiative => {
            return `<li class="text-sm">${initiative}</li>`
          }).join('')

          const content = `
            <div class="p-4">
              <h3 class="text-md font-semibold">Partnering Initiatives</h3>
              <ul class="pl-5 list-disc list-inside">
                ${partneringInitiativesContent}
              </ul>

              <h3 class="text-md font-semibold mt-2">Partnering Stakeholders</h3>
              <ul class="pl-5 list-disc list-inside">
                ${connectionNamesContent}
              </ul>

              <h3 class="text-md font-semibold mt-2">Metrics</h3>
              <ul class="pl-5 list-disc list-inside">
                <li>Connections: ${connections.length}</li>
                <li>Betweenness: ${node.betweenness}</li>
              </ul>
            </div>
          `
          dialogContentTarget.innerHTML = content
          dialogTarget.showModal();
        })
        .on('click', function(event, node) {
          event.stopPropagation();
          event.preventDefault();

          var neighbors = getNeighbors(data.links, node)

          // we modify the styles to highlight selected nodes
          nodeElements.attr('fill', function (node) { return getNodeColor(node, neighbors) })
          textElements.attr('class', function (node) { return getTextClass(node, neighbors) })
          linkElements.attr('class', function (link) { return getLinkClass(link, node) })

          updateStakeholderTypes({ target: stakeholderTypesTarget })
        })
        .on("mouseover", function(event, node) {
          var text = querySelectorIncludesText('.texts text', node.label)
          var textElement = d3.select(text)
          textElement.attr('visibility', 'visible')
        })
        .on("mouseout", function(event, node) {
          const url = new URL(window.location)
          const showLabels = url.searchParams.get('show_labels') == 'true'

          if (!showLabels) {
            var text = querySelectorIncludesText('.texts text', node.label)
            var textElement = d3.select(text)
            textElement.attr('visibility', 'hidden')
          }
        });

    var textElements = svg.append("g")
      .attr("class", "texts stroke-zinc-950 dark:stroke-white print:stroke-zinc-950 dark:print:stroke-zinc-950")
      .selectAll("text")
      .data(data.nodes)
      .enter().append("text")
        .text(function (node) { return  node.label })
        .attr("font-size", 12)
        .attr("dx", 15)
        .attr("dy", 4)
        .attr("visibility", 'hidden')

    var r = 7

    simulation.nodes(data.nodes).on('tick', () => {
      nodeElements
        .attr("cx", function(node) { return node.x = Math.max(r, Math.min(width - r, node.x)); })
        .attr("cy", function(node) { return node.y = Math.max(r, Math.min(height - r, node.y)); });
      textElements
        .attr('x', function (node) { return node.x - 5 })
        .attr('y', function (node) { return node.y - 1 })
      linkElements
        .attr('x1', function (link) { return link.source.x })
        .attr('y1', function (link) { return link.source.y })
        .attr('x2', function (link) { return link.target.x })
        .attr('y2', function (link) { return link.target.y })
    })

    simulation.force("link").links(data.links)

    this.mapTarget.append(svg.node())
  }

  getData() {
    const nodesElement = this.graphTarget.querySelector('.nodes')
    const nodeElements = nodesElement.querySelectorAll('.node')

    const linksElement = this.graphTarget.querySelector('.links')
    const linkElements = linksElement.querySelectorAll('.link')

    const nodesData = Array.from(nodeElements).map(node => {
      const partneringInitiativesString = node.getAttribute('data-partnering-initiatives')
      const partneringInitiatives = partneringInitiativesString.split(',').map(initiative => initiative.trim())

      return {
        id: node.getAttribute('data-id'),
        label: node.getAttribute('data-label'),
        color: node.getAttribute('data-color'),
        betweenness: node.getAttribute('data-betweenness'),
        stakeholderType: node.getAttribute('data-stakeholder-type'),
        partneringInitiatives: partneringInitiatives,
      }
    })

    const linksData = Array.from(linkElements).map(node => {
      return {
        id: node.getAttribute('data-id'),
        target: node.getAttribute('data-target'),
        source: node.getAttribute('data-source'),
        strength: node.getAttribute('data-strength'),
      }
    })

    return { nodes: nodesData, links: linksData };
  }

  calcForceStrength(nodes, links) { 
    return -40 
  }

  calcLinkStrength(links) {
    var x = links.length;
    var y = 0.0002063777*x - 0.00345955;
    return y
  }

  updateNodeColors(selectedStakeholderTypes) {
    const svgElement = this.mapTarget.querySelector('svg')
    const nodeElement = svgElement.querySelector('.nodes')
    const nodeElements = nodeElement.querySelectorAll('circle')

    nodeElements.forEach(element => {
      const elementData = d3.select(element).datum();
      const stakeholderType = elementData.stakeholderType
      const color = elementData.color

      if (selectedStakeholderTypes === undefined || selectedStakeholderTypes.length == 0 || selectedStakeholderTypes.includes(stakeholderType)) {
        d3.select(element).attr('fill', color)
      } else {
        d3.select(element).attr('fill', 'gray')
      }
    })
  }

  updateStakeholderTypes(event) {
    const selected = this.stakeholderTypesTarget.selectedOptions
    const selectedStakeholderTypes = Array.from(selected).map(({ value }) => value)

    const url = new URL(window.location)
    url.searchParams.delete('stakeholder_types[]')

    this.selectedStakeholderTypesForPrintTarget.innerHTML = ''

    if (selectedStakeholderTypes && selectedStakeholderTypes.length > 0) {
      this.selectedStakeholderTypesForPrintContainerTarget.classList.add('print:block')

      selectedStakeholderTypes.forEach(stakeholderType => {
        url.searchParams.append('stakeholder_types[]', stakeholderType)

        this.selectedStakeholderTypesForPrintTarget.innerHTML +=
          `<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-zinc-500 text-white" >${stakeholderType}</span>`
      })
    } else {
      this.selectedStakeholderTypesForPrintContainerTarget.classList.remove('print:block')
    }

    window.history.replaceState({}, '', url)

    this.updateNodeColors(selectedStakeholderTypes)
  }
}
