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
              x: -6
            },
            '.port-body': {
              fill: '#16A085',
              x: -10,
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
              x: 0,
              width: 10,
              height: 10,
            }
          },
          label: {
            position: {
              name: 'left',
              args: {
                x: -6,
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
      node_name = cellView.model.get('id')
      if node_name == 'root'
        port = magnet.getAttribute('port')
        links = graph.getConnectedLinks(cellView.model, { outbound: true })
        portLinks = _.filter links, (link)->
          link.get('source').port == port
        if portLinks.length > 0
          return false
      magnet.getAttribute('magnet') != 'passive'

    snapLinks: { radius: 25 },
    markAvailable: true,
    linkPinning: false,
    multiLinks: false
  })

  root_node = new joint.shapes.NodeShape({
    id: 'root',
    position: { x: 50, y: 50 },
    inPorts: [],
    outPorts: ['next_nodes'],
    attrs: { text: { text: 'Root' } }
  })
  graph.addCell(root_node)

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

  createLink = (source, target)->
    link = new joint.shapes.pn.Link({
      smooth: true,
      source: {
        id: source,
        port: 'next_nodes'
      },
      target: {
        id: target,
        port: 'in'
      }
      attrs: {
        '.connection' : { stroke: 'black', 'stroke-width': '2' },
        '.marker-target': { d: 'M 10 0 L 0 5 L 10 10 z', 'stroke-width': '3' }
      }
    });
    graph.addCell(link)

  createLink('root', job_script_data.root)
  $.each job_script_data.nodes, (name, node_descriptor)->
    if node_descriptor.next_nodes
      $.each node_descriptor.next_nodes, (index, target_name)->
        createLink(name, target_name)

  interval = setInterval(->
    if on_updated && $paper_element.is(':visible')
      on_updated(graph)
  1500)

  {graph: graph, paper: paper, interval: interval}