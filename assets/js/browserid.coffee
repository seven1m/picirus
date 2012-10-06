$ ->
  $('#browserid').click (e) ->
    e.preventDefault()
    navigator.id.get (assertion) ->
      if assertion
        $('input').val assertion
        $('form').submit()
      else
        location.reload()
