$(document).click(function (e) {
    if (!$(e.target).closest('table.clickable').length) return
    if ($(e.target).closest('.js-clickable-nofollow').length) return

    let url = $(e.target).closest('tr').data('url')
    if (url) {
        return window.location = url
    }
})
