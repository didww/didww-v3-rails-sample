form           = '.js-order-form '
notes          = '.js-order-restrictions'
toggle         = '.js-order-restrictions-toggle'
accept         = '.js-order-restrictions-accept'
submit         = form + 'button[type="submit"]'

$.onmount form, ->
  $(accept).change ->
    if $(@).prop('checked')
      $(@).closest('tr').removeClass('warning')
      $(@).closest('tr').find(notes).collapse('hide')

  $(toggle).click ->
    $(@).closest('tr').find(notes).collapse('toggle')

  $(form).submit (e) ->
    unchecked = $(accept).filter(':not(:checked)')
    if unchecked.length
      unchecked.closest('tr').addClass('warning')
      unchecked.closest('tr').find(notes).collapse('show')
      e.preventDefault()
      false

  $(accept).filter(':not(:checked)').closest('tr').find(notes).collapse('show')

  $(form).on 'keyup keypress', (e) ->
    keyCode = e.keyCode || e.which
    if keyCode == 13
      e.preventDefault()
      false
