import onmount from 'onmount'

let container = '.js-balance '
let reload_button = container + '.js-balance-reload '
let details_div = container + ' > div'
const balance_detail = function (field) {
    return $(container + '[data-balance-detail="' + field + '"] ')
}

onmount(container, function () {
    $(reload_button).click(function () {
        $(reload_button).attr('disabled', true)
        $(reload_button + 'i.fa').addClass('fa-spin')
        $.get({
            url: '/balance',
            dataType: 'json'
        }).done(function (json) {
            $(reload_button).attr('disabled', false)
            $(reload_button + 'i.fa').removeClass('fa-spin')
            $(details_div).hide().fadeIn()
            $.each(json, function (key, val) {
                balance_detail(key).text(val)
            })
        })
    })
})
