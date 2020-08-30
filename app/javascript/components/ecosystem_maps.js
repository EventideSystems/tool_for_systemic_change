
function getScorecardId() {
  return $('div#ecosystem-maps').data('scorecard-id')
}

function getScreenCoords(x, y, ctm) {
  var xn = ctm.e + x*ctm.a + y*ctm.c;
  var yn = ctm.f + x*ctm.b + y*ctm.d;
  return { x: xn, y: yn };
}

function showNodeDialog(nodeData, node, dataUrl) {
  debugger;
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

function displayInitiatives() {

  if ($('div#ecosystem-maps').data('initiatives-rendered') == true) {
    return
  }

  $('div#ecosystem-maps').data('initiatives-rendered', true)

  function getData() {
    var transitionCardId = $('div#ecosystem-maps').data('scorecard-id');
    var dataUrl = `/transition_cards/${transitionCardId}/ecosystem_maps_initiatives`;
    return $.get(dataUrl);
  };

  var div = d3.select("body").append("div")	
    .attr("class", "chart-tooltip initiatives-chart-tooltip")				
    .style("opacity", 0)

  $.when(getData()).then(function(data) {

    var nodes = data['data']['nodes'];
    var links = data['data']['links'];

    let zoom = d3.zoom().on("zoom", function () {
      svg.attr("transform", d3.event.transform)
    })

    var width = $('#initiatives-chart').width()
    var height = $('#initiatives-chart').height()
    
    var svg = d3.select('#initiatives-chart > svg')
      .attr("width", width)
      .attr("height", height)
      // .style("background-color", "#eeeeee")
      .call(zoom)
      .on("dblclick.zoom", null)
      .on("wheel.zoom", null)
      .on("dblclick", function(d){ 
        nodeElements.attr('fill', function (node) { return getNodeColor(node) })
        textElements.attr('fill', function (node) { return getTextColor(node) })
        linkElements.attr('stroke', function (link) { return '#E5E5E5' })
      });
      // .call(d3.zoom().on("zoom", function () {
      //   svg.attr("transform", d3.event.transform)
      // }));
      
    d3.select("#tab_initiatives #zoom_in").on("click", function() {
      zoom.scaleBy(svg.transition().duration(750), 1.2);
    });

    d3.select("#tab_initiatives #zoom_out").on("click", function() {
      zoom.scaleBy(svg.transition().duration(750), 0.8);
    });

    $('#tab_initiatives #show_labels').hide()

    d3.select("#tab_initiatives #hide_labels").on("click", function() {
      $('#tab_initiatives #hide_labels').hide()
      $('#tab_initiatives #show_labels').show()
      textElements.attr('opacity', function (node) { return "0.0" })
    });

    d3.select("#tab_initiatives #show_labels").on("click", function() {
      $('#tab_initiatives #hide_labels').show()
      $('#tab_initiatives #show_labels').hide()
      textElements.attr('opacity', function (node) { return "1.0" })
    });

    // simulation setup with all forces
    var linkForce = d3
      .forceLink()
      .id(function (link) { return link.id })
      .strength(function (link) { return 0.001 })

    var simulation = d3
      .forceSimulation()
      .force('link', linkForce)
      .force('charge', d3.forceManyBody().strength(-30))
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
        .attr("stroke-width", 1)
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
          var divHtml = "<h5><strong>" + d.initiative_name + "</strong></h5>"

          if (d.initiative_description) {
            divHtml += "<p><i>" + d.initiative_description + "</i></p>"
          }

          if (d.partnering_organisation_names.length) {
            divHtml += "<h6><strong>Partnering Organisations</strong></h6>"
            divHtml += "<ul>"
            d.partnering_organisation_names.forEach(function (item, index) {
              divHtml += "<li>" + item + "</li>"
            });
            divHtml += "</ul>"
          }

          if (d.subsystem_tag_names.length) {
            divHtml += "<h6><strong>Subsystem Tags</strong></h6>"
            divHtml += "<ul>"
            d.subsystem_tag_names.forEach(function (item, index) {
              divHtml += "<li>" + item + "</li>"
            });
            divHtml += "</ul>"
          }

          if (d.initiative_started_at) {
            divHtml += "<h6><strong>Started At</strong></h6>"
            divHtml += "<ul>"
            divHtml += "<li>" + d.initiative_started_at + "</li>"
            divHtml += "</ul>"
          }

          if (d.initiative_finished_at) {
            divHtml += "<h6><strong>Finished At</strong></h6>"
            divHtml += "<ul>"
            divHtml += "<li>" + d.initiative_finished_at + "</li>"
            divHtml += "</ul>"
          }
            
          div.transition()        
            .duration(200)      
            .style("opacity", 0.8);      
          div.html(divHtml)
            .style("left", ($('#initiatives-chart').first().position().left + $('#initiatives-chart').first().width() - 250) + "px")
            .style("top",  ($('#initiatives-chart').first().position().top)  + "px");      
        })                  
        .on("mouseout", function(d) {       
          div.transition()        
            .duration(500)      
            .style("opacity", 0);   
        });

    var textElements = svg.append("g")
      .attr("class", "texts")
      .selectAll("text")
      .data(nodes)
      .enter().append("text")
        .text(function (node) { return  node.label })
        .attr("font-size", 9)
        .attr("dx", 15)
        .attr("dy", 4)

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

function displayOrganisations() {

  if ($('div#ecosystem-maps').data('organisations-rendered') == true) {
    return
  }

  $('div#ecosystem-maps').data('organisations-rendered', true)

  function getData() {
    var transitionCardId = $('div#ecosystem-maps').data('scorecard-id');
    var dataUrl = `/transition_cards/${transitionCardId}/ecosystem_maps_organisations`;
    return $.get(dataUrl);
  };

  var div = d3.select("body").append("div")	
    .attr("class", "chart-tooltip organisations-chart-tooltip")				
    .style("opacity", 0)

  $.when(getData()).then(function(data) {

    var nodes = data['data']['nodes'];
    var links = data['data']['links'];

    let zoom = d3.zoom().on("zoom", function () {
      svg.attr("transform", d3.event.transform)
    })

    var width = $('#organisations-chart').width()
    var height = $('#organisations-chart').height()
    
    var svg = d3.select('#organisations-chart > svg')
      .attr("width", width)
      .attr("height", height)
      // .style("background-color", "#eeeeee")
      .call(zoom)
      .on("dblclick.zoom", null)
      .on("wheel.zoom", null)
      .on("dblclick", function(d){ 
        nodeElements.attr('fill', function (node) { return getNodeColor(node) })
        textElements.attr('fill', function (node) { return getTextColor(node) })
        linkElements.attr('stroke', function (link) { return '#E5E5E5' })
      });
      // .call(d3.zoom().on("zoom", function () {
      //   svg.attr("transform", d3.event.transform)
      // }));
      
    d3.select("#tab_organisations #zoom_in").on("click", function() {
      zoom.scaleBy(svg.transition().duration(750), 1.2);
    });

    d3.select("#tab_organisations #zoom_out").on("click", function() {
      zoom.scaleBy(svg.transition().duration(750), 0.8);
    });

    $('#show_legend').hide()

    d3.select("#tab_organisations #hide_legend").on("click", function() {
      $('#tab_organisations .legend').hide()
      $('#tab_organisations #hide_legend').hide()
      $('#tab_organisations #show_legend').show()
    });

    d3.select("#show_legend").on("click", function() {
      $('#tab_organisations .legend').show()
      $('#tab_organisations #hide_legend').show()
      $('#tab_organisations #show_legend').hide()
    });

    $('#tab_organisations #show_labels').hide()

    d3.select("#tab_organisations #hide_labels").on("click", function() {
      $('#tab_organisations #hide_labels').hide()
      $('#tab_organisations #show_labels').show()
      textElements.attr('opacity', function (node) { return "0.0" })
    });

    d3.select("#tab_organisations #show_labels").on("click", function() {
      $('#tab_organisations #hide_labels').show()
      $('#tab_organisations #show_labels').hide()
      textElements.attr('opacity', function (node) { return "1.0" })
    });

    // simulation setup with all forces
    var linkForce = d3
      .forceLink()
      .id(function (link) { return link.id })
      .strength(function (link) { return link.strength })

    var simulation = d3
      .forceSimulation()
      .force('link', linkForce)
      .force('charge', d3.forceManyBody().strength(-50))
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
        .attr("stroke-width", 1)
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
        .on("mouseenter", function(d) {
          var dataUrl = `/ecosystem_maps/${getScorecardId()}/organisations/${d['id']}`;

          ctm = this.getScreenCTM();
          coords = getScreenCoords(d.x, d.y, ctm);

          var boundingRect = document
            .querySelector('#organisations-chart')
            .getBoundingClientRect();

          var absoluteRect = $('#organisations-chart').offset();

          var my = absoluteRect.top - boundingRect.top + 50;
          //var mx = absoluteRect.left - boundingRect.left + d['x'] - 10;

          var mx = coords.x + 10;

          maxContentHeight = $(window).height() - (my + 20);

          showNodeDialog(this, d, dataUrl);

          $('#ecosystem-maps-modal').modal({backdrop: false})
          $('#ecosystem-maps-modal').find(".modal-content").load(dataUrl);
          $('#ecosystem-maps-modal').css('top', my);
          $('#ecosystem-maps-modal').css('left', mx);
          $('#ecosystem-maps-modal .modal-content').css('max-height', maxContentHeight);
          $('#ecosystem-maps-modal').modal('show');
        })                  
        .on("mouseout", function(d) {       
          div.transition()        
            .duration(500)      
            .style("opacity", 0);   
        });

    var textElements = svg.append("g")
      .attr("class", "texts")
      .selectAll("text")
      .data(nodes)
      .enter().append("text")
        .text(function (node) { return  node.label })
        .attr("font-size", 9)
        .attr("dx", 15)
        .attr("dy", 4)

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
