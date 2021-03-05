const showHideOrderSelected = function () {
    const selected = $(".js-select-row:not([disabled]):checked").length > 0
    $(".js-disable-when-select-nothing").attr("disabled", !selected)
}

const checkSelectAll = function () {
    const $selectAll = $(".js-select-all")
    const hasSelectable = $(".js-select-row:not([disabled])").length > 0
    if (!hasSelectable) {
        $selectAll.prop("checked", false).prop("disabled", true)
    } else {
        const hasNotSelected = $(".js-select-row:not([disabled]):not(:checked)").length > 0
        $selectAll.prop("checked", !hasNotSelected).prop("disabled", false)
    }
}

/* public functions in selectAllLogic namespace */
const selectAllLogic = {
    showHideOrderSelected,
    checkSelectAll,
    disableRow($row) {
        $row.removeClass("selected").addClass("disabled")
        $row.find(".js-select-row").attr("disabled", true).prop("checked", false)
        checkSelectAll()
        showHideOrderSelected()
    },
    unselectAll() {
        $("tr:not(.disabled)").removeClass("selected")
        $(".js-select-row:not([disabled])").prop("checked", false)
        checkSelectAll()
        showHideOrderSelected()
    },
    selectAll() {
        $("tr:not(.disabled)").addClass("selected")
        $(".js-select-row:not([disabled])").prop("checked", true)
        checkSelectAll()
        showHideOrderSelected()
    }
}

export default selectAllLogic
