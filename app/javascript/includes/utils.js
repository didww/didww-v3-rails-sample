const selectedOptionFor = function ($select) {
    return $select.find(`> option[value="${$select.val()}"]`)
}

const buttonLoadingState = function ($btn, isLoading) {
    if (isLoading) {
        $btn.attr("disabled", true)
        $btn.find("> i").addClass("fa-spinner fa-pulse")
    } else {
        $btn.attr("disabled", false)
        $btn.find("> i").removeClass("fa-spinner fa-pulse")
    }
}

// success warning danger
const addFlashMessage = function (type, content) {
    const alert = $(
        "<div>",
        { class: `alert alert-${type}` }
    ).append(
        $("<button>", { class: "close", "data-dismiss": "alert", "aria-hidden": "true" }).html("&times"),
        $("<div>").append(content)
    )
    $(".js-flash-wrapper").append(alert)
}

export {
    selectedOptionFor,
    buttonLoadingState,
    addFlashMessage
}
