@createCodeMirror = (text_area, mode, on_updated)->
  code_mirror = CodeMirror.fromTextArea(text_area, {
    mode: mode,
    lineNumbers: true,
    tabSize: 2
  })
  code_mirror.on 'blur', ->
    $(text_area).val(code_mirror.getValue())
    if on_updated
      on_updated()
  code_mirror

@autoSaveForm = ($form, method)->
  form_updated = ->
    path = $form.attr('action')
    $.ajax({url: path, type: method, data: $form.serialize()}).success (response)->
      console.log(response)
    false
  $form.find(':input').change(form_updated)
  form_updated