import Rails from "@rails/ujs";
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [
    "activities",
    "targetsNetworkMap",
    "targetsNetworkMapLabelsBtn",
    "targetsNetworkMapLegendBtn",
    "targetsNetworkMapLegendPanel",
    "targetsNetworkMapDialog",
    "organisationsFilter",
    "initiativesFilter",
  ]

  connect() {
    this.select2mount()

    document.addEventListener("turbolinks:before-cache", () => {
      this.select2unmount()
    }, { once: true })
  }

  applyFilter(event) {
    let context = this

    let organisations = $(this.organisationsFilterTarget).val()
    let initiatives = $(this.initiativesFilterTarget).val()

    let nodes = d3.selectAll('#target-network-map-container svg g.nodes circle').nodes()

    debugger

    if (organisations.length == 0 && initiatives.length == 0) {
      nodes.forEach(function(node) {
        data = d3.select(node).data()[0]
        $(node).attr('fill', data.color)
      })
    } else {
      nodes.forEach(function(node) {
        let data = d3.select(node).data()[0]

        let filterByOrganisations = $(organisations).filter(data.organisation_ids).length > 0
        let filterByInitiatives = $(initiatives).filter(data.initiative_ids).length > 0

        if (filterByOrganisations || filterByInitiatives) {
          $(node).attr('fill', '#f00')
        } else {
          $(node).attr('fill', '#eee')
        }
      })
    }
  }

  loadActivities(event) {
    event.preventDefault()

    let activitiesTarget = this.activitiesTarget;
    let loadPath = window.location.pathname + '/activities';

    Rails.ajax({
      type: "get",
      url: loadPath,
      success: function(data) { activitiesTarget.innerHTML = data.body.getInnerHTML() },
      error: function(data) { alert('Error') }
    })
  }

  loadTargetsNetworkMap(event) {
    event.preventDefault()

    let target = $(this.targetsNetworkMapTarget);
    let dialog = $('#ecosystem-maps-modal');

    let loadPath = window.location.pathname + '/targets_network_map.json';

    function calcLinkStrength(nodes, links) {
      // x = links.length;
      // y = 0.0002063777*x - 0.00345955;
      return 0.5
    }

    function calcForceStrength(nodes, links) {
     // x = links.length / nodes.length
     // y = (−282.914 * Math.pow(x, 2)) + (1409.871 * x) − 1884.819
      return -50
    }

    function getScreenCoords(x, y, ctm) {
      var xn = ctm.e + x*ctm.a + y*ctm.c;
      var yn = ctm.f + x*ctm.b + y*ctm.d;
      return { x: xn, y: yn };
    }

    function showNodeDialog(nodeData, node) {
      closeNodeDialog()

      if (node.characteristic_id == undefined) { return }

      let ctm = nodeData.getScreenCTM();
      let coords = getScreenCoords(node.x, node.y, ctm);

      $('#ecosystem-maps-modal').data('coords-x', coords.x);
      $('#ecosystem-maps-modal').data('coords-y', coords.y);
      $('#ecosystem-maps-modal').css('opacity', 0);

      let dataUrl = window.location.pathname + '/characteristics/' + node.characteristic_id;

      $('#ecosystem-maps-modal').find(".modal-content").load(dataUrl, function() {
        $('#ecosystem-maps-modal').modal('show');
      });
    }

    function closeNodeDialog() {
      $('#ecosystem-maps-modal').modal({ backdrop: false, draggable: true });
      $('#ecosystem-maps-modal').modal('hide');
    }

    function getNeighbors(links, node) {
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

    function isNeighborLink(node, link) {
      return link.target.id === node.id || link.source.id === node.id
    }

    function getNodeColor(node, neighbors) {
      if (Array.isArray(neighbors) && neighbors.indexOf(node.id) > -1) {
        return node.level === 1 ? '#499BC4' : '#49C472'
      }

      var nodeColor = node.color

      return nodeColor;
    }

    function getNodeSize(node) {
      var nodeSize = node.size

      return nodeSize;
    }

    function getLinkColor(node, link) {
      return isNeighborLink(node, link) ? 'green' : '#E5E5E5'
    }

    function getTextColor(node, neighbors) {
      return Array.isArray(neighbors) && neighbors.indexOf(node.id) > -1 ? 'green' : 'black'
    }

    function labelsVisible() {
      return $('[data-target="ecosystem-maps.toggleLabels"]').hasClass('active')
    }

    Rails.ajax({
      type: "get",
      url: loadPath,
      success: function(data) {
        const links = data['data'].links
        const nodes = data['data'].nodes

        $("#target-network-map-container svg").remove();

        var width = target.width(),
            height = target.height() * 1.5;

        let zoom = d3.zoom().on("zoom", function () {
          svg.attr("transform", d3.event.transform)
        })

        var svg = d3.select('#target-network-map-container')
          .append("svg")
          .attr("width", width)
          .attr("height", height)
          .call(zoom)
          .on("click", function(event) {
            closeNodeDialog()
          })
          .on("dblclick", function(event) {
            nodeElements.attr('fill', function (node) { return getNodeColor(node) })
            textElements.attr('fill', function (node) { return getTextColor(node) })
            linkElements.attr('stroke', function (link) { return '#E5E5E5' })
          })
          .on("dblclick.zoom", null)
          .on("wheel.zoom", null)

        // simulation setup with all forces
        var linkForce = d3
          .forceLink()
          .id(function (link) { return link.id })
          .strength(calcLinkStrength(nodes, links))

        var simulation = d3
          .forceSimulation()
          .force('link', linkForce)
          .force('charge', d3.forceManyBody().strength(calcForceStrength(nodes, links)))
          .force('center', d3.forceCenter(width / 2.5, height / 3))
          .force('collide', d3.forceCollide(function (d) { return getNodeSize(d) + 10 }))


        var dragDrop = d3.drag().on('start', function (node) {
          node.fx = node.x
          node.fy = node.y
        }).on('drag', function (node) {
          simulation.alphaTarget(0.7).restart()
          node.fx = d3.event.x
          node.fy = d3.event.y
        }).on('end', function (node) {
          if (!d3.event.active) {
            simulation.alphaTarget(0)
          }
          node.fx = null
          node.fy = null
        })

        function selectNode(selectedNode) {
          var neighbors = getNeighbors(links, selectedNode)

          // we modify the styles to highlight selected nodes
          nodeElements.attr('fill', function (node) { return getNodeColor(node, neighbors) })
          textElements.attr('fill', function (node) { return getTextColor(node, neighbors) })
          linkElements.attr('stroke', function (link) { return getLinkColor(selectedNode, link) })
        }

        var linkElements = svg.append("g")
          .attr("class", "links")
          .selectAll("line")
          .data(links)
          .enter().append("line")
            .attr("stroke-width", function(d) { return d['strength'] })
            .attr("stroke", "rgba(50, 50, 50, 0.2)")

        var nodeElements = svg.append("g")
          .attr("class", "nodes")
          .selectAll("circle")
          .data(nodes)
          .enter().append("circle")
            .attr("r", getNodeSize)
            .attr("fill", getNodeColor)
            .call(dragDrop)
            .on('click', function(d) {
              showNodeDialog(this, d);
            })
            .on('dblclick', function(d) {
              d3.event.stopPropagation();
              selectNode(d)
            })
            .on("mouseover", function(d) {
              var text = $(`.texts text:contains("${d.label}")`)[0]
              var textElement = d3.select(text)
              textElement.attr('visibility', 'visible')
            })
            .on("mouseout", function(d) {
              if (!labelsVisible()) {
                var text = $(`.texts text:contains("${d.label}")`)[0]
                var textElement = d3.select(text)
                textElement.attr('visibility', 'hidden')
              }
            });

        var labelVisibility = function() {
          if (labelsVisible()) {
            return "visible"
          } else {
            return "hidden"
          }
        }

        var textElements = svg.append("g")
          .attr("class", "texts")
          .selectAll("text")
          .data(nodes)
          .enter().append("text")
            .text(function (node) { return  node.label })
            .attr("font-size", 9)
            .attr("dx", 15)
            .attr("dy", 4)
            .attr("visibility", labelVisibility)

        var r = 7

        simulation.nodes(nodes).on('tick', () => {
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

        simulation.force("link").links(links)
      },
      error: function() { alert('Error') }
    });
  }

  select2mount() {
    var context = this

    $(this.organisationsFilterTarget).select2({
      dropdownAutoWidth: true,
      multiple: true,
      placeholder: "Select Organisations",
    }).on('select2:select select2:unselect', function (e) {
      context.applyFilter(e)
    });

    $(this.initiativesFilterTarget).select2({
      dropdownAutoWidth: true,
      multiple: true,
      placeholder: "Select Initiatives",
    }).on('select2:select select2:unselect', function (e) {
      context.applyFilter(e)
    });
  }

  select2unmount() {
    $(this.organisationsFilterTarget).select2('destroy');
    $(this.initiativesFilterTarget).select2('destroy');
  }

  toggleNetworkMapLabels(event) {
    event.preventDefault()

    let visible = $(this.targetsNetworkMapLabelsBtnTarget).toggleClass('active').hasClass('active')

    $('#target-network-map-container svg g.texts text').attr('visibility', function (node) {
      if (visible) { return 'visible' } else { return 'hidden' }
    })
  }

  toggleNetworkMapLegend(event) {
    event.preventDefault()

    let visible = $(this.targetsNetworkMapLegendBtnTarget).toggleClass('active').hasClass('active')

    if (visible) {
      $(this.targetsNetworkMapLegendPanelTarget).show()
    } else {
      $(this.targetsNetworkMapLegendPanelTarget).hide()
    }
  }


}
