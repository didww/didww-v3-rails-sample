import onmount from "onmount"
import selectAllLogic from "./select_all_logic"

onmount(".js-select-row", function () {
    $(this).on("change", function () {
        const isChecked = $(this).is(":checked")
        const $tr = $(this).closest("tr")
        if (isChecked) {
            $tr.addClass("selected")
        } else {
            $tr.removeClass("selected")
        }
        selectAllLogic.checkSelectAll()
        selectAllLogic.showHideOrderSelected()
    })
})

onmount(".js-select-all", function () {
    selectAllLogic.showHideOrderSelected()
    $(this).on("change", function () {
        const isChecked = $(this).is(":checked")
        if (isChecked) {
            selectAllLogic.selectAll()
        } else {
            selectAllLogic.unselectAll()
        }
        selectAllLogic.showHideOrderSelected()
    })
})
