import { Controller } from "@hotwired/stimulus"
import * as d3 from "d3"

export default class extends Controller {

  static targets = ["map", "graph"]

  connect() {
    const data = this.getData();
    this.drawGraph(data)
  }

  drawGraph(data) {

    const width = 960
    const height = 960

    var linkForce = d3
      .forceLink()
      .id(function (link) { return link.id })
      .strength(this.calcLinkStrength(data.links))

    var simulation = d3
      .forceSimulation()
      .force('link', linkForce)
      .force('charge', d3.forceManyBody().strength(this.calcForceStrength(data.nodes, data.links)))
      .force('center', d3.forceCenter(width / 2.5, height / 3))

    const svg = d3.create("svg")
      .attr("width", width)
      .attr("height", height);


    var linkElements = svg.append("g")
      .attr("class", "links")
      .selectAll("line")
      .data(data.links)
      .enter().append("line")
        .attr("stroke-width", function(d) { return d['strength'] })
        .attr("stroke", "rgba(50, 50, 50, 0.2)")

    var nodeElements = svg.append("g")
      .attr("class", "nodes")
      .selectAll("circle")
      .data(data.nodes)
      .enter().append("circle")
        .attr("r", 6)
        .attr("fill", this.getNodeColor)

    var textElements = svg.append("g")
      .attr("class", "texts")
      .selectAll("text")
      .data(data.nodes)
      .enter().append("text")
        .text(function (node) { return  node.label })
        .attr("font-size", 9)
        .attr("dx", 15)
        .attr("dy", 4)
        .attr("visibility", true)

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
    const linksElement = this.graphTarget.querySelector('.links')

    const nodeElements = nodesElement.querySelectorAll('.node')
    const linkElements = linksElement.querySelectorAll('.link')

    const nodesData = Array.from(nodeElements).map(node => {
      return {
        id: node.getAttribute('data-id'),
        label: node.getAttribute('data-label'),
        color: node.getAttribute('data-color'),
        betweenness: node.getAttribute('data-betweenness'),
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

  getNodeColor(node, neighbors) {
    if (Array.isArray(neighbors) && neighbors.indexOf(node.id) > -1) {
      return node.level === 1 ? '#499BC4' : '#49C472'
    }

    return  node.color;
  }

  calcForceStrength(nodes, links) { return -40 }

  calcLinkStrength(links) {
    var x = links.length;
    var y = 0.0002063777*x - 0.00345955;
    return y
  }

}
