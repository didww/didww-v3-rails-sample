import onMount from 'onmount'

const form = '.js-order-form '
const notes = '.js-order-restrictions'
const toggle = '.js-order-restrictions-toggle'
const accept = '.js-order-restrictions-accept'
// const submit = `${form}button[type="submit"]`

onMount(form, () => {
  $(accept).change(function () {
    if ($(this).prop('checked')) {
      $(this).closest('tr').removeClass('warning')
      return $(this).closest('tr').find(notes).collapse('hide')
    }
    return undefined
  })

  $(toggle).click(function () {
    return $(this).closest('tr').find(notes).collapse('toggle')
  })

  $(form).submit((e) => {
    const unchecked = $(accept).filter(':not(:checked)')
    if (unchecked.length) {
      unchecked.closest('tr').addClass('warning')
      unchecked.closest('tr').find(notes).collapse('show')
      e.preventDefault()
      return false
    }
    return undefined
  })

  $(accept).filter(':not(:checked)').closest('tr').find(notes)
    .collapse('show')

  return $(form).on('keyup keypress', (e) => {
    const keyCode = e.keyCode || e.which
    if (keyCode === 13) {
      e.preventDefault()
      return false
    }
    return undefined
  })
})
