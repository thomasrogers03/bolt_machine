# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('#job_job_script_attributes_id').length > 0
    $form = $('form.edit_job')
    job_id = $('#job-meta-data').data('job-id')
    job_script_data = $('#job-meta-data').data('job-script-json')
    form_updated = autoSaveForm $form, 'PATCH', ->
      $.get('/jobs/' + job_id + '/script/json').success (response)->
        job_script_data = response
        $('#job-meta-data').data('job-script-json', job_script_data)

    node_graph_updated = (graph)->
      $.each graph.getElements(), (index, element)->
        node_name = element.get('id')
        graph_node_type = element.get('graph_node_type')
        if graph_node_type == 'node'
          node_descriptor = job_script_data.nodes[node_name]

          position = element.get('position')
          node_descriptor.x = position.x
          node_descriptor.y = position.y
          node_descriptor.next_nodes = []
          node_descriptor.inputs = {}
          node_descriptor.outputs = {}

      $.each graph.getLinks(), (index, link)->
        node_name = link.get('source').id
        target_node_name = link.get('target').id

        element = graph.getCell(node_name)
        graph_node_type = element.get('graph_node_type')
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

      $.get('/jobs/json_to_yaml', {json: JSON.stringify(job_script_data)}).success (response)->
        code_mirror.setValue(response)
        $(script_box).val(response)
        form_updated()
    node_graph = createJobNodeGraph('#job-designer', job_script_data, node_graph_updated)

    script_box = document.getElementById('job_job_script_attributes_script')
    code_mirror = createCodeMirror script_box, 'yaml', ->
      form_updated()

    test_variable_box = document.getElementById('job-test-variables')
    test_variable_code = createCodeMirror(test_variable_box, 'yaml', null)

    $execute_form = $('form.execute_job')
    @executeJobTest = ->
      input_values = test_variable_code.getValue()
      $('#job-test-variables').val(input_values)
      path = $execute_form.attr('action')

      $run_job_button = $('#run-test-job')
      $run_job_button.prop('disabled', true)
      $.post(path, {execution_values: input_values}).success (response)->
        $('#job-test-result').val(response)
        test_result_code.setValue(response)
        $run_job_button.prop('disabled', false)
      .error ->
        response = 'Job unable to run!'
        $('#job-test-result').val(response)
        test_result_code.setValue(response)
        $run_job_button.prop('disabled', false)
      false

    test_result_box = document.getElementById('job-test-result')
    test_result_code = createCodeMirror(test_result_box, 'yaml', null)
    test_result_code.setOption("readOnly", true)

    $('a[data-toggle="tab"]').on 'shown.bs.tab', ->
      code_mirror.refresh()
      test_variable_code.refresh()
      test_result_code.refresh()
      if $('#job-designer-tab').is(':visible')
        clearJobNodeGraph('#job-designer-tab', node_graph)
        node_graph = createJobNodeGraph('#job-designer', job_script_data, node_graph_updated)


$(document).ready(ready)
$(document).on('page:load', ready)

