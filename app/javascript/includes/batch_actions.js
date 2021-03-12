import onmount from 'onmount'
import createElement from './create_element'

const BATCH_ACTIONS_MODAL = '#batch-action-modal'
const BATCH_ACTIONS_DROPDOWN = '#batch-actions-dropdown'
const BATCH_ACTIONS_CHECKBOXES = '.batch-action-checkbox'
const BATCH_ACTIONS_SELECT_ALL_CHECKBOX = '#batch-action-select-all-checkbox'
const BATCH_ACTIONS_SUBMIT_BUTTON = '.batch-action-submit'

function disableSubmitBtn() {
    const submitBtn = $(`${ BATCH_ACTIONS_MODAL } ${ BATCH_ACTIONS_SUBMIT_BUTTON }`)
    submitBtn.attr('disabled', 'disabled')
}

function enableSubmitBtn() {
    const submitBtn = $(`${ BATCH_ACTIONS_MODAL } ${ BATCH_ACTIONS_SUBMIT_BUTTON }`)
    submitBtn.removeAttr('disabled')
}

function buildHiddenInputs(name) {
    let html = [
        createElement('input', { type: 'hidden', name: 'name', value: name })
    ]
    gatherRecordsIds().forEach(id => {
        html.push(
            createElement('input', { type: 'hidden', name: 'record_ids[]', value: id })
        )
    })
    return html.join("\n")
}

function gatherRecordsIds() {
    const ids = []
    $.each($(BATCH_ACTIONS_CHECKBOXES + ':checked'), function () {
        ids.push($(this).val())
    })
    return ids
}

function selectAll() {
    // console.log(BATCH_ACTIONS_CHECKBOXES, 'set checked')
    $(BATCH_ACTIONS_CHECKBOXES).prop('checked', 'checked')
}

function deselectAll() {
    // console.log(BATCH_ACTIONS_CHECKBOXES, 'set not checked')
    $(BATCH_ACTIONS_CHECKBOXES).prop('checked', '')
}

function clearModal() {
    const modal = $(BATCH_ACTIONS_MODAL)
    modal.find('.modal-header .modal-title').text('')
    modal.find('.modal-body').html('')
}

function fillLoadingModal(name) {
    const modal = $(BATCH_ACTIONS_MODAL)
    modal.find('.modal-header .modal-title').text(name)
    modal.find('.modal-body').html(
        createElement('span', { class: 'text-warning' }, 'Loading...')
    )
    disableSubmitBtn()
}

function fillModal(name, data) {
    // console.log('fillModal', name, data)
    const modal = $(BATCH_ACTIONS_MODAL)
    modal.find('.modal-body').html(buildHiddenInputs(name) + "\n" + data)
    enableSubmitBtn()
}

function fillErrorModal(error) {
    const modal = $(BATCH_ACTIONS_MODAL)
    modal.find('.modal-body').html(
        createElement('span', { class: 'text-danger' }, error)
    )
}

function openModal(name) {
    const modal = $(BATCH_ACTIONS_MODAL)
    if (modal.length === 0) {
        console.error('batch action modal is missing')
        return
    }

    fillLoadingModal(name)
    modal.modal('show')
    $.ajax({
        url: '/dids/batch_action_content',
        method: 'POST',
        data: { name: name, record_ids: gatherRecordsIds() },
        success: function (data) {
            fillModal(name, data)
        },
        error: function (error) {
            if (error.responseJSON) {
                fillErrorModal(error.responseJSON.error)
            } else {
                fillErrorModal('Server error')
            }
        }
    })
}

function isSelectAllChecked() {
    // console.log('BATCH_ACTIONS_SELECT_ALL_CHECKBOX', 'checked', $(BATCH_ACTIONS_SELECT_ALL_CHECKBOX).is(':checked'))
    return $(BATCH_ACTIONS_SELECT_ALL_CHECKBOX).is(':checked')
}

function checkBatchActionsSelect() {
    const dropdownBtn = $(BATCH_ACTIONS_DROPDOWN).find('.dropdown-toggle')
    const hasSelectedRecords = $(BATCH_ACTIONS_CHECKBOXES + ':checked').length > 0
    // console.log('checkBatchActionsSelect', hasSelectedRecords, select[0], $(BATCH_ACTIONS_CHECKBOXES + ':checked'))

    if (hasSelectedRecords) {
        dropdownBtn.removeAttr('disabled')
        dropdownBtn.removeClass('disabled')
    } else {
        dropdownBtn.attr('disabled', 'disabled')
        dropdownBtn.addClass('disabled')
    }
}

function initialize() {
    $(BATCH_ACTIONS_SELECT_ALL_CHECKBOX).on('click', function () {
        // console.log(BATCH_ACTIONS_SELECT_ALL_CHECKBOX, 'changed', isSelectAllChecked())
        isSelectAllChecked() ? selectAll() : deselectAll()
        checkBatchActionsSelect()
    })

    $(BATCH_ACTIONS_CHECKBOXES).on('click', function () {
        checkBatchActionsSelect()
    })

    $(BATCH_ACTIONS_MODAL).on('hidden.bs.modal', function () {
        clearModal()
    })

    $(`${ BATCH_ACTIONS_DROPDOWN } ul.dropdown-menu li a`).on('click', function (event) {
        event.preventDefault()
        const name = $(event.currentTarget).data('name')
        if (name) openModal(name)
    })

    // fix when going back in browser history
    $(BATCH_ACTIONS_SELECT_ALL_CHECKBOX).prop('checked', '')
    deselectAll()
}

onmount(BATCH_ACTIONS_MODAL, function () {
    initialize()
})
