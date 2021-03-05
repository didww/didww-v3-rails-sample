import onmount from 'onmount'

const form = '.js-order-form '
const notes = '.js-order-restrictions'
const toggle = '.js-order-restrictions-toggle'
const accept = '.js-order-restrictions-accept'
const submit = form + 'button[type="submit"]'

onmount(form, function () {
    $(accept).change(function () {
        if ($(this).prop('checked')) {
            $(this).closest('tr').removeClass('warning')
            $(this).closest('tr').find(notes).collapse('hide')
        }
    })

    $(toggle).click(function () {
        $(this).closest('tr').find(notes).collapse('toggle')
    })

    $(form).submit(function (e) {
        const unchecked = $(accept).filter(':not(:checked)')
        if (unchecked.length) {
            unchecked.closest('tr').addClass('warning')
            unchecked.closest('tr').find(notes).collapse('show')
            e.preventDefault()
            return false
        }
    })

    $(accept).filter(':not(:checked)').closest('tr').find(notes).collapse('show')

    $(form).on('keyup keypress', function (e) {
        const keyCode = e.keyCode || e.which
        if (keyCode === 13) {
            e.preventDefault()
            return false
        }
    })
})
