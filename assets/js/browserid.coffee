$ ->
  $('#browserid').click (e) ->
    e.preventDefault()
    navigator.id.get (assertion) ->
      if assertion
        $.ajax '/auth/browserid',
          type: 'post'
          cache: false
          data:
            assertion: assertion
          statusCode:
            200: (data) ->
              app.console.setUsername data.username
              app.console.focus()
      else
        location.reload()
