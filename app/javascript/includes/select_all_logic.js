import onmount from 'onmount'

let showHideOrderSelected = function () {
    let selected = $('.js-select-row:not([disabled]):checked').length > 0
    $('.js-disable-when-select-nothing').attr('disabled', !selected)
}

let checkSelectAll = function () {
    let $selectAll = $('.js-select-all')
    let hasSelectable = $('.js-select-row:not([disabled])').length > 0
    if (!hasSelectable) {
        $selectAll.prop('checked', false).prop('disabled', true)
    } else {
        let hasNotSelected = $('.js-select-row:not([disabled]):not(:checked)').length > 0
        $selectAll.prop('checked', !hasNotSelected).prop('disabled', false)
    }
}

/* public functions in selectAllLogic namespace */
window.selectAllLogic = {
    disableRow: function ($row) {
        $row.removeClass('selected').addClass('disabled')
        $row.find('.js-select-row').attr('disabled', true).prop('checked', false)
        checkSelectAll()
        showHideOrderSelected()
    },
    unselectAll: function () {
        $('tr:not(.disabled)').removeClass('selected')
        $('.js-select-row:not([disabled])').prop('checked', false)
        checkSelectAll()
        showHideOrderSelected()
    },
    selectAll: function () {
        $('tr:not(.disabled)').addClass('selected')
        $('.js-select-row:not([disabled])').prop('checked', true)
        checkSelectAll()
        showHideOrderSelected()
    }
}

onmount('.js-select-row', function () {
    $(this).on('change', function () {
        let isChecked = $(this).is(":checked")
        let $tr = $(this).closest('tr')
        if (isChecked) {
            $tr.addClass('selected')
        } else {
            $tr.removeClass('selected')
        }
        checkSelectAll()
        showHideOrderSelected()
    })
})

onmount('.js-select-all', function () {
    showHideOrderSelected()
    $(this).on('change', function () {
        let isChecked = $(this).is(":checked")
        if (isChecked) {
            selectAllLogic.selectAll()
        } else {
            selectAllLogic.unselectAll()
        }
        showHideOrderSelected()
    })
})
