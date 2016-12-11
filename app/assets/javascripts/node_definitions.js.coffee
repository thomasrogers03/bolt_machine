# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('#node_definition_script').length > 0
    script_box = document.getElementById('node_definition_script')
    CodeMirror.fromTextArea(script_box, {
      mode: 'ruby',
      lineNumbers: true,
      tabSize: 2,

    })

    meta_data_box = document.getElementById('node_definition_meta_data')
    CodeMirror.fromTextArea(meta_data_box, {
      mode: 'javascript',
      lineNumbers: true,
      tabSize: 2,

    })

    @updateNode = ()->
      $form = $('form.edit_node_definition')
      path = $form.attr('action')
      $.ajax({url: path, type: 'PATCH', data: $form.serialize()}).success (response)->
        console.log(response)
      false

$(document).ready(ready)
$(document).on('page:load', ready)

