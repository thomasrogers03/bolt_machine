# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('#job_job_script_attributes_id').length > 0
    $form = $('form.edit_job')
    job_id = $('#job-meta-data').data('job-id')
    job_script_data = $('#job-meta-data').data('job-script-json')
    node_meta_data = $('#job-meta-data').data('node-meta-data')
    form_updated = autoSaveForm $form, 'PATCH', ->
      $.get('/jobs/' + job_id + '/script/json').success (response)->
        job_script_data = response
        $('#job-meta-data').data('job-script-json', job_script_data)

    node_graph_updated = (job_script_data)->
      $.post('/jobs/json_to_yaml', {json: JSON.stringify(job_script_data)}).success (response)->
        code_mirror.setValue(response)
        $(script_box).val(response)
        form_updated()

    property_change = (properties, type, name)->
      ->
        value = $(this).val()
        if type == 'any'
          float_value = parseFloat(value)
          unless isNaN(float_value)
            value = float_value
        properties[name] = value
    node_selected = (node_definition, node_descriptor, node)->
      $('#node-property-table').html('')
      if node
        property_table = $('#node-property-table')
        property_templated = _.template($('#node-property-template').html())
        $.each node_definition.properties, (name, type)->
          property_html = property_templated(name: name, type: type)
          property_table.append(property_html)
          input = property_table.find('.property-input:last')
          input.val(node_descriptor.properties[name])
          input.on('change keyup paste mouseup', property_change(node_descriptor.properties, type, name))

    node_graph = createJobNodeGraph('#job-designer', node_meta_data, job_script_data, node_graph_updated, node_selected)

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
        node_graph = createJobNodeGraph('#job-designer', node_meta_data, job_script_data, node_graph_updated, node_selected)


$(document).ready(ready)
$(document).on('page:load', ready)

