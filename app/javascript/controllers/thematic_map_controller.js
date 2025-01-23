import { Controller } from "@hotwired/stimulus"
import * as d3 from "d3"

export default class extends Controller {

  static targets = [
    "map", "graph", "filterForm", "toggleLabelsButton", "dialog", "dialogContent", "dialogTitle",
    "dialogTitleColor", "dialogContent", "stakeholders", "initiatives",
    "selectedStakeholdersForPrint", "selectedInitiativesForPrint",
    "selectedStakeholdersForPrintContainer", "selectedInitiativesForPrintContainer"
  ]

  connect() {
    window.addEventListener('beforeprint', this.beforePrint.bind(this));
    window.addEventListener('afterprint', this.afterPrint.bind(this));

    const data = this.getData()
    this.drawGraph(data)

    this.toggleLabelsButtonTarget.addEventListener("click", this.toggleLabels.bind(this))
    this.stakeholdersTarget.addEventListener("change", this.updateFilters.bind(this))
    this.initiativesTarget.addEventListener("change", this.updateFilters.bind(this))

    this.updateLabelsVisibility = this.updateLabelsVisibility.bind(this)
    this.updateFilters = this.updateFilters.bind(this)

    this.updateFilters()
    this.updateLabelsVisibility()
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

    this.mapTarget.setAttribute('height', bounds.height + 50);
    svg.setAttribute('height', bounds.height + 50);
  }

  drawGraph(data) {
    const width = this.mapTarget.clientWidth
    const height = this.mapTarget.clientHeight

    let getNeighbors = this.getNeighbors
    let getLinkClass = this.getLinkClass
    let getNodeColor = this.getNodeColor
    let getTextClass = this.getTextClass
    let getNodeSize = this.getNodeSize // NOTE: This function looks a bit redundant

    let dialogTarget = this.dialogTarget
    let dialogTitleTarget = this.dialogTitleTarget
    let dialogTitleColorTarget = this.dialogTitleColorTarget
    let dialogContentTarget = this.dialogContentTarget

    let querySelectorIncludesText = this.querySelectorIncludesText.bind(this)
    // let updateStakeholderTypes = this.updateStakeholderTypes.bind(this)

    // let stakeholderTypesTarget = this.stakeholderTypesTarget

    var linkForce = d3
      .forceLink()
      .id(function (link) { return link.id })
      .strength(this.calcLinkStrength(data.links))

    var dragDrop = d3.drag().on('start', function (node) {
        node.fx = node.x
        node.fy = node.y
      }).on('drag', function (event, node) {
        simulation.alphaTarget(0.7).restart()
        node.fx = event.x
        node.fy = event.y
      }).on('end', function (event, node) {
        if (!event.active) {
          simulation.alphaTarget(0)
        }
        node.fx = null
        node.fy = null
      })

    var simulation = d3
      .forceSimulation()
      .force('link', linkForce)
      .force('charge', d3.forceManyBody().strength(this.calcForceStrength(data.nodes, data.links)))
      .force('center', d3.forceCenter(width / 2.5, height / 3))
      .force('collide', d3.forceCollide(function (event, node) { return getNodeSize(node) + 10 }))

    const svg = d3.create("svg")
      .attr("width", width)
      .attr("height", height)

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
        .attr("r", getNodeSize)
        .attr("fill", this.getNodeColor)
        .call(dragDrop)
        .on('dblclick', function(event, node) {
          event.stopPropagation();

          const nodeElement = document.querySelector(`[data-id='${node.id}']`);
          const nodeDescription = nodeElement.querySelector('.description').innerHTML

          dialogTitleTarget.innerHTML = node.label
          dialogTitleColorTarget.style.backgroundColor = node.color

          const descriptionContent = nodeDescription.trim().length ? nodeDescription : '<span class="italic">No description<span>'

          var partneringInitiativesContent = node.initiatives.map(initiative => {
            return `<li>${initiative}</li>`
          }).join('')

          var partneringStakeholdersContent = node.stakeholders.map(stakeholder => {
            return `<li>${stakeholder}</li>`
          }).join('')


          if (!partneringInitiativesContent.length) {
            partneringInitiativesContent = '<li class="italic">No partnering initiatives</li>'
          }

          if (!partneringStakeholdersContent.length) {
            partneringStakeholdersContent = '<li class="italic">No partnering stakeholders</li>'
          }

          const content = `
            <div class="p-4">
              <p>${descriptionContent}</p>
              <h3 class="mt-2 text-md font-semibold">Partnering Initiatives</h3>
              <ul class="pl-5 list-disc">
                ${partneringInitiativesContent}
              </ul>

              <h3 class="mt-2 text-md font-semibold">Partnering Stakeholders</h3>
              <ul class="pl-5 list-disc">
                ${partneringStakeholdersContent}
              </ul>
            </div>
          `
          dialogContentTarget.innerHTML = content
          dialogTarget.showModal();
        })
        .on('click', function(event, node) {
          event.stopPropagation();
          var neighbors = getNeighbors(data.links, node)

          // we modify the styles to highlight selected nodes
          nodeElements.attr('fill', function (node) { return getNodeColor(node, neighbors) })
          textElements.attr('class', function (node) { return getTextClass(node, neighbors) })
          linkElements.attr('class', function (link) { return getLinkClass(link, node) })

          // updateStakeholderTypes({ target: stakeholderTypesTarget })
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

      const stakeholdersString = node.getAttribute('data-stakeholders') || '[]'
      const stakeholders = JSON.parse(stakeholdersString)

      const initiativesString = node.getAttribute('data-initiatives') || '[]'
      const initiatives = JSON.parse(initiativesString)

      return {
        id: node.getAttribute('data-id'),
        label: node.getAttribute('data-label'),
        color: node.getAttribute('data-color'),
        size: node.getAttribute('data-size'),
        characteristicId: node.getAttribute('data-characteristic-id'),
        stakeholders: stakeholders,
        initiatives: initiatives
      }
    })

    const linksData = Array.from(linkElements).map(node => {
      return {
        id: node.getAttribute('data-id'),
        target: node.getAttribute('data-target'),
        source: node.getAttribute('data-source'),
      }
    })

    return { nodes: nodesData, links: linksData };
  }

  querySelectorIncludesText(selector, text) {
    return Array.from(document.querySelectorAll(selector))
      .find(el => el.textContent.includes(text));
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

  getLinkClass(link, node) {
    if (link.target.id === node.id || link.source.id === node.id) {
      return 'links stroke-green-300 dark:stroke-green-300'
    } else {
      return 'links stroke-zinc-400 dark:stroke-zinc-400'
    }
  }

  getNodeColor(node, neighbors) {
    if (Array.isArray(neighbors) && neighbors.includes(node.id)) {
      return '#49C472'
    } else  {
      return node.color
    }
  }

  getNodeSize(node) {
    var nodeSize = node.size

    return nodeSize;
  }

  getTextClass(node, neighbors) {
    if (Array.isArray(neighbors) && neighbors.includes(node.id)) {
      return 'texts stroke-green-300 dark:stroke-green-300'
    } else {
      return 'texts stroke-zinc-400 dark:stroke-zinc-400'
    }
  }

  calcForceStrength(nodes, links) { return -40 }

  calcLinkStrength(links) {
    return 0.38
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

  updateFilters(event) {
    const selectedStakeholders = Array.from(this.stakeholdersTarget.selectedOptions).map(({ value }) => value)
    const selectedInitiatives = Array.from(this.initiativesTarget.selectedOptions).map(({ value }) => value)

    const url = new URL(window.location)
    url.searchParams.delete('stakeholders[]')
    url.searchParams.delete('initiatives[]')

    this.selectedStakeholdersForPrintTarget.innerHTML = ''
    this.selectedInitiativesForPrintTarget.innerHTML = ''

    if (selectedStakeholders && selectedStakeholders.length > 0) {
      this.selectedStakeholdersForPrintContainerTarget.classList.add('print:block')
      selectedStakeholders.forEach(stakeholder => {
        url.searchParams.append('stakeholders[]', stakeholder)

        this.selectedStakeholdersForPrintTarget.innerHTML +=
          `<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-zinc-500 text-white" >${stakeholder}</span>`
      })
    } else {
      this.selectedStakeholdersForPrintContainerTarget.classList.remove('print:block')
    }

    if (selectedInitiatives && selectedInitiatives.length > 0) {
      this.selectedInitiativesForPrintContainerTarget.classList.add('print:block')
      selectedInitiatives.forEach(initiative => {
        url.searchParams.append('initiatives[]', initiative)

        this.selectedInitiativesForPrintTarget.innerHTML +=
          `<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-zinc-500 text-white" >${initiative}</span>`
      })
    } else {
      this.selectedInitiativesForPrintContainerTarget.classList.remove('print:block')
    }

    window.history.replaceState({}, '', url)

    const svgElement = this.mapTarget.querySelector('svg')
    const nodeElement = svgElement.querySelector('.nodes')
    const nodeElements = nodeElement.querySelectorAll('circle')

    nodeElements.forEach(element => {
      const elementData = d3.select(element).datum();
      const stakeholders = elementData.stakeholders
      const initiatives = elementData.initiatives
      const color = elementData.color

      const intersectStakeholders = selectedStakeholders.some(stakeholder => stakeholders.includes(stakeholder))
      const intersectsInitiatives = selectedInitiatives.some(initiative => initiatives.includes(initiative))

      if ((selectedStakeholders.length === 0 && selectedInitiatives.length === 0 ) || (intersectStakeholders || intersectsInitiatives)) {
        d3.select(element).attr('fill', color)
      } else {
        console.log('nope')
        d3.select(element).attr('fill', 'gray')
      }
    })
  }
}
