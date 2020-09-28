function getScorecardId() {
  return $('div#ecosystem-maps').data('scorecard-id')
}

function getScreenCoords(x, y, ctm) {
  var xn = ctm.e + x*ctm.a + y*ctm.c;
  var yn = ctm.f + x*ctm.b + y*ctm.d;
  return { x: xn, y: yn };
}

function showNodeDialog(nodeData, node, dataUrl) {
  ctm = nodeData.getScreenCTM();
  coords = getScreenCoords(node.x, node.y, ctm);

  $('#ecosystem-maps-modal').data('coords-x', coords.x);
  $('#ecosystem-maps-modal').data('coords-y', coords.y);
  $('#ecosystem-maps-modal').css('opacity', 0);
  
  $('#ecosystem-maps-modal').find(".modal-content").load(dataUrl, function() {
    $('#ecosystem-maps-modal').modal({ backdrop: false, draggable: true });
    $('#ecosystem-maps-modal').modal('show');
  });
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

  nodeColor = node.color

  return nodeColor;
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

function displayMap(mapDiv, mapData, getNodeUrl, forceStrength) {
  if ($(mapDiv).data('rendered') == true) {
    return
  }

  $(mapDiv).data('rendered', true)

  $.when(mapData()).then(function(data) {

    var nodes = data['data']['nodes'];
    var links = data['data']['links'];

    let zoom = d3.zoom().on("zoom", function () {
      svg.attr("transform", d3.event.transform)
    })

    var width = $(mapDiv).width()
    var height = $(mapDiv).height()
    
    var svg = d3.select(`${mapDiv} > svg`)
      .attr("width", width)
      .attr("height", height)
      .call(zoom)
      .on("dblclick.zoom", null)
      .on("wheel.zoom", null)
      .on("dblclick", function(d){ 
        nodeElements.attr('fill', function (node) { return getNodeColor(node) })
        textElements.attr('fill', function (node) { return getTextColor(node) })
        linkElements.attr('stroke', function (link) { return '#E5E5E5' })
      });

    // simulation setup with all forces
    var linkForce = d3
      .forceLink()
      .id(function (link) { return link.id })
      .strength(function (link) { return 0.001 })

    var simulation = d3
      .forceSimulation()
      .force('link', linkForce)
      .force('charge', d3.forceManyBody().strength(forceStrength))
      .force('center', d3.forceCenter(width / 3, height / 3))

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
        .attr("r", 6)
        .attr("fill", getNodeColor)
        .call(dragDrop)
        .on('click', selectNode)
        .on("mouseover", function(d) {  
          var dataUrl = getNodeUrl(d);
          showNodeDialog(this, d, dataUrl);    
        })                  
        .on("mouseout", function(d) {       
          div.transition()        
            .duration(500)      
            .style("opacity", 0);   
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

        // .attr('cx', function (node) { return node.x })
        // .attr('cy', function (node) { return node.y })
      textElements
        .attr('x', function (node) { return node.x })
        .attr('y', function (node) { return node.y })
      linkElements
        .attr('x1', function (link) { return link.source.x })
        .attr('y1', function (link) { return link.source.y })
        .attr('x2', function (link) { return link.target.x })
        .attr('y2', function (link) { return link.target.y })
    })
  
    simulation.force("link").links(links)
  });
}

function displayInitiatives() {

  function getData() {
    var transitionCardId = $('div#ecosystem-maps').data('scorecard-id');
    var dataUrl = `/transition_cards/${transitionCardId}/ecosystem_maps_initiatives`;
    return $.get(dataUrl);
  };

  function getNodeUrl(node) {
    return `/ecosystem_maps/${getScorecardId()}/initiatives/${node['id']}`
  }

  displayMap('#initiatives-chart', getData, getNodeUrl, -30)
}

function displayOrganisations() {

  function getData() {
    var transitionCardId = $('div#ecosystem-maps').data('scorecard-id');
    var dataUrl = `/transition_cards/${transitionCardId}/ecosystem_maps_organisations`;
    return $.get(dataUrl);
  };

  function getNodeUrl(node) {
    return `/ecosystem_maps/${getScorecardId()}/organisations/${node['id']}?betweenness=${node['betweenness']}`
  }

  displayMap('#organisations-chart', getData, getNodeUrl, -30)
}

$(document).on('turbolinks:load', function() {
  $('a[data-target="#tab_organisations"]').on('shown.bs.tab', function (e) {
    displayOrganisations();
  });

  $('a[data-target="#tab_initiatives"]').on('shown.bs.tab', function (e) {
    displayInitiatives();
  });

  $('a[data-target="#ecosystem_maps"]').on('shown.bs.tab', function (e) {
    displayOrganisations();
  });
});
