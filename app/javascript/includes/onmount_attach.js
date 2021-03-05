import onmount from "onmount"
import initDraggableMultiselect from "./draggable_multiselect"

onmount(".js-metismenu", function () {
    $(this).metisMenu()
})

onmount(".js-two-way-select", function () {
    initDraggableMultiselect($(this))
})

$(document).on("ready turbolinks:load turbolinks:render ajaxComplete", () => {
    onmount()
})
