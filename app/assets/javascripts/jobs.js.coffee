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

    script_box = document.getElementById('job_job_script_attributes_script')
    code_mirror = createCodeMirror(script_box, 'yaml', form_updated)

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
        console.log(response)
        $run_job_button.prop('disabled', false)
      .error ->
        response = 'Job unable to run!'
        $('#job-test-result').val(response)
        test_result_code.setValue(response)
        console.log(response)
        $run_job_button.prop('disabled', false)
      false


    test_result_box = document.getElementById('job-test-result')
    test_result_code = createCodeMirror(test_result_box, 'yaml', null)
    test_result_code.setOption("readOnly", true)

    node_graph = node_graph_updated = (graph)->
      $.each graph.getElements(), (index, element)->
        node_name = element.get('node_name')
        node_descriptor = job_script_data.nodes[node_name]

        position = element.get('position')
        node_descriptor.x = position.x
        node_descriptor.y = position.y
      $.get('/jobs/json_to_yaml', {json: JSON.stringify(job_script_data)}).success (response)->
        code_mirror.setValue(response)
        $(script_box).val(response)
        form_updated()

    createJobNodeGraph('#job-designer', job_script_data, node_graph_updated)

    $('a[data-toggle="tab"]').on 'shown.bs.tab', ->
      code_mirror.refresh()
      test_variable_code.refresh()
      test_result_code.refresh()


$(document).ready(ready)
$(document).on('page:load', ready)

