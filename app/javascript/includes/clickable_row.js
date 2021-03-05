$(document).click((e) => {
    if (!$(e.target).closest("table.clickable").length) return
    if ($(e.target).closest(".js-clickable-nofollow").length) return

    const url = $(e.target).closest("tr").data("url")
    if (url) window.location = url
})
