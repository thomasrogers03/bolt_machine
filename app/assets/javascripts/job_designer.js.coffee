joint.shapes.NodeShape = joint.shapes.devs.Model.extend({
  markup: '<g class="rotatable"><rect class="body"/><rect class="title"/><text class="label"/></g>',
  portMarkup: '<rect class="port-body"/>',

  defaults: joint.util.deepSupplement({
    type: 'NodeShape'
    size: {
      width: 100,
      height: 100
    }
    ports: {
      groups: {
        'in': {
          attrs: {
            '.port-label': {
              'font-size': 8,
            },
            '.port-body': {
              fill: '#16A085',
              width: 10,
              height: 10
            }
          },
          label: {
            position: {
              name: 'right',
              args: {
                x: 12,
                y: 4
              }
            }
          }
        },
        'out': {
          attrs: {
            '.port-label': {
              'font-size': 8
            },
            '.port-body': {
              fill: '#E74C3C'
              x: -10,
              width: 10,
              height: 10,
            }
          },
          label: {
            position: {
              name: 'left',
              args: {
                x: -12
                y: 4
              }
            }
          }
        }
      }
    },
    attrs: {
      '.title': {
        fill: 'red', rx: 5, ry: 5, width: 100, height: 20, y: -20
      }
      '.body': {
        rx: 5, ry: 5,
        fill: 'blue'
      },
      '.label': {
        y: 5, fill: 'white', y: -15
      }
    }
  }, joint.shapes.devs.Model.prototype.defaults)
})

@clearJobNodeGraph = (designer_tab, node_graph)->
  node_graph.graph.clear()
  node_graph.paper.remove()
  clearInterval(node_graph.interval)
  $(designer_tab).prepend('<div id="job-designer" />')

@createJobNodeGraph = (paper_element, job_script_data, on_updated)->
  $paper_element = $(paper_element)
  graph = new joint.dia.Graph

  paper = new joint.dia.Paper({
    el: $paper_element,
    width: '100%',
    height: 800,
    model: graph,
    gridSize: 1,
    defaultLink: new joint.dia.Link({
      smooth: true,
      attrs: {
        '.connection' : { stroke: 'black' },
        '.marker-target': { d: 'M 10 0 L 0 5 L 10 10 z' }
      }
    }),
    validateConnection: (cellViewS, magnetS, cellViewT, magnetT, end, linkView)->
      unless magnetT
        return false

      if cellViewS == cellViewT
        return false

      if magnetS && magnetS.getAttribute('port-group') == magnetT.getAttribute('port-group')
        return false
      magnetS != magnetT
    validateMagnet: (cellView, magnet)->
      magnet.getAttribute('magnet') != 'passive'

    snapLinks: { radius: 25 },
    markAvailable: true,
    linkPinning: false,
    multiLinks: false
  })

  $.each job_script_data.nodes, (name, node_descriptor)->
    x = if node_descriptor.x
      node_descriptor.x
    else
      100
    y = if node_descriptor.y
      node_descriptor.y
    else
      30
    node = new joint.shapes.NodeShape({
      node_type: node_descriptor.type,
      id: name,
      properties: {},
      position: { x: x, y: y },
      inPorts: ['in'],
      outPorts: ['next_nodes'],
      attrs: { text: { text: name } }
    })
    graph.addCell(node)

  $.each job_script_data.nodes, (name, node_descriptor)->
    if node_descriptor.next_nodes
      $.each node_descriptor.next_nodes, (index, target_name)->
        link = new joint.shapes.pn.Link({
          smooth: true,
          source: {
            id: name,
            port: 'next_nodes'
          },
          target: {
            id: target_name,
            port: 'in'
          }
          attrs: {
            '.connection' : { stroke: 'black' },
            '.marker-target': { d: 'M 10 0 L 0 5 L 10 10 z' }
          }
        });
        graph.addCell(link)

  interval = setInterval(->
    if on_updated && $paper_element.is(':visible')
      on_updated(graph)
  1500)

  {graph: graph, paper: paper, interval: interval}