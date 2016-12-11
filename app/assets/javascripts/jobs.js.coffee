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


$(document).ready(ready)
$(document).on('page:load', ready)

