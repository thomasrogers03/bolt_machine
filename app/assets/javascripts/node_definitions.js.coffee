# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('#node_definition_script').length > 0
    $form = $('form.edit_node_definition')
    form_updated = ->
      path = $form.attr('action')
      $.ajax({url: path, type: 'PATCH', data: $form.serialize()}).success (response)->
        console.log(response)
      false
    $form.find(':input').change(form_updated)

    script_box = document.getElementById('node_definition_script')
    script_code = CodeMirror.fromTextArea(script_box, {
      mode: 'ruby',
      lineNumbers: true,
      tabSize: 2
    })
    script_code.on 'blur', ->
      $('#node_definition_script').val(script_code.getValue())
      form_updated()

    meta_data_box = document.getElementById('node_definition_meta_data')
    meta_data_code = CodeMirror.fromTextArea(meta_data_box, {
      mode: 'yaml',
      lineNumbers: true,
      tabSize: 2
    })
    meta_data_code.on 'blur', ->
      $('#node_definition_meta_data').val(meta_data_code.getValue())
      form_updated()

$(document).ready(ready)
$(document).on('page:load', ready)

