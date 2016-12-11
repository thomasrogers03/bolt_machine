# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('#job_job_script_attributes_id').length > 0
    script_box = document.getElementById('job_job_script_attributes_script')
    code_mirror = CodeMirror.fromTextArea(script_box, {
      mode: 'ruby',
      lineNumbers: true,
      tabSize: 2,

    })

    $.get('/jobs/1/json').success (response)->
      pretty_json = JSON.stringify(response, null, 2)
      $('#job-graph-text').val(pretty_json)

    @updateJob = (event)->
      $form = $('form.edit_job')
      $.ajax({url: '/jobs/1', type: 'PATCH', data: $form.serialize()}).success (response)->
        $.get('/jobs/1/json').success (response)->
          pretty_json = JSON.stringify(response, null, 2)
          $('#job-graph-text').val(pretty_json)
      false

$(document).ready(ready)
$(document).on('page:load', ready)

