# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('#node_definition_script').length > 0
    $form = $('form.edit_node_definition')
    form_updated = autoSaveForm($form, 'PATCH')

    script_box = document.getElementById('node_definition_script')
    createCodeMirror(script_box, 'ruby', form_updated)

    meta_data_box = document.getElementById('node_definition_meta_data')
    createCodeMirror(meta_data_box, 'yaml', form_updated)

$(document).ready(ready)
$(document).on('page:load', ready)

