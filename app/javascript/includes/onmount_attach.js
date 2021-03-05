import onmount from 'onmount'

onmount('.js-metismenu', function () {
    $(this).metisMenu()
})

onmount('.js-two-way-select', function () {
    initDraggableMultiselect($(this))
})

$(document).on('ready turbolinks:load turbolinks:render ajaxComplete', function () {
    onmount()
})
