joint.shapes.NodeShape = joint.shapes.devs.Model.extend({
  markup: '<g class="rotatable"><rect class="body"/><rect class="title"/><text class="label"/></g>',
  portMarkup: '<rect class="port-body"/>',

  defaults: joint.util.deepSupplement({
    type: 'NodeShape'
    size: {
      width: 200,
      height: 100
    }
    ports: {
      groups: {
        'in': {
          attrs: {
            '.port-label': {
              'font-size': 12,
              'font-weight': 'bold',
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
              'font-size': 12,
              'font-weight': 'bold'
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
        fill: 'red', rx: 5, ry: 5, width: 200, height: 20, y: -20
      }
      '.body': {
        rx: 5, ry: 5,
        fill: '#00000000',
        stroke: '#B95BAE',
        'stroke-width': '2',
      },
      '.label': {
        fill: 'white', y: -15
      }
    }
  }, joint.shapes.devs.Model.prototype.defaults)
})

joint.shapes.VariableShape = joint.shapes.devs.Model.extend({
  markup: '<g class="rotatable"><g class="scalable"><circle class="body"/></g><text class="label"/></g>',
  portMarkup: '<rect class="port-body"/>',
  portLabelMarkup: '',

  defaults: joint.util.deepSupplement({
    type: 'VariableShape'
    size: {
      width: 60,
      height: 60
    }
    ports: {
      groups: {
        'in': {
          attrs: {
            '.port-body': {
              fill: '#16A085',
              x: 25,
              y: -40,
              width: 10,
              height: 10
            }
          }
        }
      }
    },
    attrs: {
      '.body': {
        fill: '#00000000',
        stroke: '#B95BAE',
        'stroke-width': '2',
        r: 30,
        cx: 30,
        cy: 30
      },
      '.label': {
        y: 5, fill: 'white', y: 20
      }
    }
  }, joint.shapes.devs.Model.prototype.defaults)
})

@clearJobNodeGraph = (designer_tab, node_graph)->
  node_graph.graph.clear()
  node_graph.paper.remove()
  clearInterval(node_graph.interval)
  $(designer_tab).prepend('<div id="job-designer" />')

@createJobNodeGraphNode = (graph, node_meta_data, name, node_descriptor)->
  x = if node_descriptor.x
    node_descriptor.x
  else
    100
  y = if node_descriptor.y
    node_descriptor.y
  else
    30

  unless node_descriptor.properties
    node_descriptor.properties = {}

  node_definition = node_meta_data[node_descriptor.type]
  node_in_ports = $.merge(['in'], node_definition.inputs)
  node_out_ports = $.merge(['out'], node_definition.outputs)

  node = new joint.shapes.NodeShape({
    node_type: node_descriptor.type,
    id: name,
    graph_node_type: 'node',
    properties: {},
    position: { x: x, y: y },
    inPorts: node_in_ports,
    outPorts: node_out_ports,
    attrs: { text: { text: name } }
  })

  node.portProp('in', 'connection_type', 'node')
  node.portProp('out', 'connection_type', 'node')
  $.each node_definition.inputs, (index, source)->
    node.portProp(source, 'connection_type', 'variable')
    node.portProp(source, 'variable_type', 'input')
  $.each node_definition.outputs, (index, source)->
    node.portProp(source, 'connection_type', 'variable')
    node.portProp(source, 'variable_type', 'output')

  graph.addCell(node)

@createJobNodeGraphVariable = (graph, name, variable_descriptor)->
  x = if variable_descriptor.x
    variable_descriptor.x
  else
    100
  y = if variable_descriptor.y
    variable_descriptor.y
  else
    30

  node = new joint.shapes.VariableShape({
    id: name,
    graph_node_type: 'variable',
    position: { x: x, y: y },
    inPorts: ['in'],
    outPorts: [],
    attrs: { text: { text: name } }
  })
  node.portProp('in', 'connection_type', 'node')
  graph.addCell(node)

@selectContextMenuNode = (event)->
  event.preventDefault()
  $('#job-designer-context-menu').hide()

  $context_menu = $('#job-designer-context-menu')
  $context_menu_item = $(event.target)
  graph = $context_menu.data('graph')
  node_meta_data = $context_menu.data('node_meta_data')
  job_script_data = $context_menu.data('job_script_data')
  position = $context_menu.data('position')
  node_type = $context_menu_item.text()

  name = node_type + ' ' + Object.keys(job_script_data.nodes).length
  job_script_data.nodes[name] = node_descriptor = { type: node_type, x: position.x, y: position.y }
  createJobNodeGraphNode(graph, node_meta_data, name, node_descriptor)
  false

@selectContextMenuVariable = (event)->
  event.preventDefault()
  $('#job-designer-context-menu').hide()

  $context_menu = $('#job-designer-context-menu')
  $context_menu_item = $(event.target)
  graph = $context_menu.data('graph')
  node_meta_data = $context_menu.data('node_meta_data')
  job_script_data = $context_menu.data('job_script_data')
  position = $context_menu.data('position')
  node_type = $context_menu_item.text()

  name = node_type + ' ' + Object.keys(job_script_data.variables).length
  job_script_data.variables[name] = variable_descriptor = { x: position.x, y: position.y }
  createJobNodeGraphVariable(graph, name, variable_descriptor)
  false

@createJobNodeGraph = (paper_element, node_meta_data, job_script_data, on_updated, on_node_selected)->
  $paper_element = $(paper_element)
  graph = new joint.dia.Graph

  paper = new joint.dia.Paper({
    el: $paper_element,
    width: '100%',
    height: 600,
    model: graph,
    gridSize: 1,
    defaultLink: new joint.dia.Link({
      smooth: true,
      attrs: {
        '.connection' : { stroke: 'black', 'stroke-width': '2' },
        '.marker-target': { d: 'M 10 0 L 0 5 L 10 10 z', 'stroke-width': '3' }
      }
    }),
    validateConnection: (cellViewS, magnetS, cellViewT, magnetT, end, linkView)->
      unless magnetT
        return false

      if cellViewS == cellViewT
        return false

      target_node_type = cellViewT.model.get('graph_node_type')

      port = magnetS.getAttribute('port')
      connection_type = cellViewS.model.portProp(port, 'connection_type')
      if connection_type != target_node_type
        return false

      if target_node_type == 'node'
        if magnetS && magnetS.getAttribute('port-group') == magnetT.getAttribute('port-group')
          return false

      magnetS != magnetT
    validateMagnet: (cellView, magnet)->
      node_type = cellView.model.get('graph_node_type')
      port = magnet.getAttribute('port')
      connection_type = cellView.model.portProp(port, 'connection_type')
      if node_type == 'root' || connection_type == 'variable'
        links = graph.getConnectedLinks(cellView.model, { outbound: true })
        portLinks = _.filter links, (link)->
          link.get('source').port == port
        if portLinks.length > 0
          return false
      node_type != 'variable' && magnet.getAttribute('magnet') != 'passive'

    snapLinks: { radius: 25 },
    markAvailable: true,
    linkPinning: false,
    multiLinks: false
  })

  selected_node = null
  paper.on 'blank:pointerclick', ()->
    if selected_node
      selected_node.unhighlight()
      selected_node = null
      if on_node_selected
        on_node_selected(null, null, null)
  paper.on 'cell:pointerclick', (cell_view, evt, x, y)->
    node = cell_view.model
    node_type = node.get('graph_node_type')
    if node_type == 'node'
      if selected_node
        selected_node.unhighlight()
      cell_view.highlight()
      selected_node = cell_view
      if on_node_selected
        node_descriptor = job_script_data.nodes[node.id]
        node_definition = node_meta_data[node_descriptor.type]
        on_node_selected(node_definition, node_descriptor, node)

  paper.on 'blank:contextmenu', (event)->
    $context_menu = $('#job-designer-context-menu')
    $context_menu.data('graph', graph)
    $context_menu.data('node_meta_data', node_meta_data)
    $context_menu.data('job_script_data', job_script_data)
    $context_menu.data('position', {x: event.offsetX, y: event.offsetY})
    $context_menu.css({left: event.offsetX, top: event.offsetY})
    $context_menu.show()

  paper.on 'blank:pointerclick', ()->
    $('#job-designer-context-menu').hide()

  root_node = new joint.shapes.NodeShape({
    id: 'root',
    graph_node_type: 'root',
    position: { x: 50, y: 50 },
    inPorts: [],
    outPorts: ['out'],
    attrs: { text: { text: 'Root' } }
  })
  root_node.portProp('out', 'connection_type', 'node')

  graph.addCell(root_node)

  job_variables = job_script_data.variables
  unless job_variables
    job_variables = {}
  appendVariable = (name)->
    unless job_variables[name]
      job_variables[name] = {}

  unless job_script_data.nodes
    job_script_data.nodes = {}

  $.each job_script_data.nodes, (name, node_descriptor)->
    if node_descriptor.inputs
      $.each node_descriptor.inputs, (source, variable_name)->
        appendVariable(variable_name)
    if node_descriptor.outputs
      $.each node_descriptor.outputs, (source, variable_name)->
        appendVariable(variable_name)

    createJobNodeGraphNode(graph, node_meta_data, name, node_descriptor)

  $.each job_variables, (name, variable_descriptor)->
    createJobNodeGraphVariable(graph, name, variable_descriptor)

  createLink = (source, source_port, target)->
    link = new joint.shapes.pn.Link({
      smooth: true,
      source: {
        id: source,
        port: source_port
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

  createLink('root', 'out', job_script_data.root)
  $.each job_script_data.nodes, (name, node_descriptor)->
    if node_descriptor.next_nodes
      $.each node_descriptor.next_nodes, (index, target_name)->
        createLink(name, 'out', target_name)
    if node_descriptor.inputs
      $.each node_descriptor.inputs, (source, variable_name)->
        createLink(name, source, variable_name)
    if node_descriptor.outputs
      $.each node_descriptor.outputs, (source, variable_name)->
        createLink(name, source, variable_name)

  interval = setInterval(->
    if on_updated && $paper_element.is(':visible')
      unless job_script_data.variables
        job_script_data.variables = {}
      unless job_script_data.nodes
        job_script_data.nodes = {}

      $.each graph.getElements(), (index, element)->
        node_name = element.get('id')
        graph_node_type = element.get('graph_node_type')
        position = element.get('position')
        if graph_node_type == 'node'
          node_descriptor = job_script_data.nodes[node_name]

          node_descriptor.x = position.x
          node_descriptor.y = position.y
          node_descriptor.next_nodes = []
          node_descriptor.inputs = {}
          node_descriptor.outputs = {}
        else if graph_node_type == 'variable'
          variable_descriptor = job_script_data.variables[node_name]
          unless variable_descriptor
            job_script_data.variables[node_name] = variable_descriptor = {}
          variable_descriptor.x = position.x
          variable_descriptor.y = position.y

      $.each graph.getLinks(), (index, link)->
        node_name = link.get('source').id
        target_node_name = link.get('target').id

        element = graph.getCell(node_name)
        graph_node_type = element.get('graph_node_type')
        if target_node_name
          if graph_node_type == 'root'
            job_script_data.root = target_node_name
          else if graph_node_type == 'node'
            target_node_type = graph.getCell(target_node_name).get('graph_node_type')
            node_descriptor = job_script_data.nodes[node_name]
            if target_node_type == 'node'
              node_descriptor.next_nodes.push(target_node_name)
            else if target_node_type == 'variable'
              port = link.get('source').port
              variable_type = element.portProp(port, 'variable_type')
              if variable_type == 'input'
                node_descriptor.inputs[port] = target_node_name
              if variable_type == 'output'
                node_descriptor.outputs[port] = target_node_name

      on_updated(job_script_data)
  1500)

  {graph: graph, paper: paper, interval: interval}