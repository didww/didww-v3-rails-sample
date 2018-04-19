$(document).click(e => {
    if ($(e.target).closest('table.clickable').length) {
        if (!$(e.target).closest('.js-clickable-nofollow').length) {
            const url = $(e.target).closest('tr').data('url')
            if (url) {
                return window.location = url
            }
        }
    }
})
