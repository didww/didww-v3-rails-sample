$(document).click (e) ->
  if $(e.target).closest('table.clickable').length
    unless $(e.target).closest('.js-clickable-nofollow').length
      if url = $(e.target).closest('tr').data('url')
        window.location = url
