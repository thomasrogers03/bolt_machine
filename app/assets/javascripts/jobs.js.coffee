# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('#job_job_script_attributes_id').length > 0
    $form = $('form.edit_job')
    form_updated = ->
      path = $form.attr('action')
      $.ajax({url: path, type: 'PATCH', data: $form.serialize()}).success (response)->
        console.log(response)
      false

    script_box = document.getElementById('job_job_script_attributes_script')
    code_mirror = CodeMirror.fromTextArea(script_box, {
      mode: 'yaml',
      lineNumbers: true,
      tabSize: 2
    })

    code_mirror.on 'blur', ->
      $('#job_job_script_attributes_script').val(code_mirror.getValue())
      form_updated()

    test_variable_box = document.getElementById('job-test-variables')
    test_variable_code = CodeMirror.fromTextArea(test_variable_box, {
      mode: 'yaml',
      lineNumbers: true,
      tabSize: 2
    })

    $execute_form = $('form.execute_job')
    @executeJobTest = ->
      input_values = test_variable_code.getValue()
      $('#job-test-variables').val(input_values)
      path = $execute_form.attr('action')
      $.post(path, {execution_values: input_values}).success (response)->
        $('#job-test-result').val(response)
        test_result_code.setValue(response)
        console.log(response)
      .error ->
        response = 'Job unable to run!'
        $('#job-test-result').val(response)
        test_result_code.setValue(response)
        console.log(response)
      false


    test_result_box = document.getElementById('job-test-result')
    test_result_code = CodeMirror.fromTextArea(test_result_box, {
      mode: 'yaml',
      lineNumbers: true,
      tabSize: 2,
      readOnly: true
    })

    $('a[data-toggle="tab"]').on 'shown.bs.tab', ->
      code_mirror.refresh()
      test_variable_code.refresh()
      test_result_code.refresh()


$(document).ready(ready)
$(document).on('page:load', ready)

