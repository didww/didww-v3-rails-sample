import "../includes/utils.js"
import "../includes/select_all_logic.js"
import "../includes/sku_prices_in_table.js"
import { addFlashMessage, buttonLoadingState } from "../includes/utils"
import onmount from 'onmount'

let buildOrderItemPayload = function ($tr) {
    return {
        available_did_id: $tr.data('available-did-id'),
        sku_id: $tr.find('.js-available-did-sku-select-wrapper > select').val(),
        in: true
    }
}

onmount('.js-available-dids-refresh', function () {
    let $this = $(this)
    $this.on('click', function () {
        buttonLoadingState($this, true)
        // location.reload(true)
        Turbolinks.visit(location.toString(), { action: 'replace' })
    })
})

onmount('.js-reserve-did-modal-save', function () {
    $(this).on('click', function () {
        let $this = $(this)
        let $modal = $('.js-reserve-did-modal')
        let availableDidId = $modal.find('input[name="available_did_id"]').val()
        let $tr = $('.js-table-available-dids').find('tr[data-available-did-id="' + availableDidId + '"]')
        let $td = $tr.find('> td:last-child')
        let payload = {
            available_did_id: availableDidId,
            description: $modal.find('input[name="description"]').val()
        }
        buttonLoadingState($this, true)
        $.ajax({
            url: '/did_reservations',
            dataType: 'json',
            method: 'POST',
            data: { did_reservation: payload },
            success: function (data) {
                buttonLoadingState($this, false)
                let link = $('<a>', { href: '/did_reservations/' + data.did_reservation.id }).text('See Reservation')
                $td.empty()
                $td.append(link)
                $modal.modal('hide')
                addFlashMessage('success', ["Reservation was created successfully. ", link.clone()])
                selectAllLogic.disableRow($tr)
            },
            error: function (error) {
                buttonLoadingState($this, false)
                $modal.modal('hide')
                addFlashMessage('danger', error.responseJSON.error)
            }
        })
    })
})

onmount('.js-reserve-available-did', function () {
    $(this).on('click', function () {
        let $this = $(this)
        let $tr = $this.closest('tr')
        let $modal = $('.js-reserve-did-modal')
        $modal.find('input[name="description"]').val('')
        $modal.find('input[name="available_did_id"]').val($tr.data('available-did-id'))
        $modal.modal('show')
    })
})

onmount('.js-order-available-did', function () {
    $(this).on('click', function () {
        let $this = $(this)
        let $tr = $this.closest('tr')
        let $td = $this.closest('td')
        let payload = {
            order: { items_attributes: [buildOrderItemPayload($tr)] }
        }
        buttonLoadingState($this, true)
        $.ajax({
            url: '/orders',
            method: 'POST',
            dataType: 'json',
            data: payload,
            success: function (data) {
                buttonLoadingState($this, false)
                let link = $('<a>', { href: '/orders/' + data.order.id }).text('See Order')
                $td.empty()
                $td.append(link)
                addFlashMessage('success', ["Order was created successfully. ", link.clone()])
                selectAllLogic.disableRow($tr)
            },
            error: function (error) {
                buttonLoadingState($this, false)
                addFlashMessage('danger', error.responseJSON.error)
            }
        })
    })
})

onmount('.js-available-did-order-selected', function () {
    $(this).on('click', function () {
        let $this = $(this)
        var $selectedRows = $('tbody > tr.selected').toArray()
        var payload = {
            order: {
                items_attributes: $selectedRows.map(function (tr) {
                    return buildOrderItemPayload($(tr))
                })
            }
        }
        buttonLoadingState($this, true)
        $.ajax({
            url: '/orders',
            method: 'POST',
            dataType: 'json',
            data: payload,
            success: function (data) {
                buttonLoadingState($this, false)
                var link = $('<a>', { href: '/orders/' + data.order.id }).text('See Order')
                addFlashMessage('success', ["Order was created successfully. ", link])
                $selectedRows.forEach(function (row) {
                    var $row = $(row)
                    $row.find('> td:last-child').empty().append(link.clone())
                    selectAllLogic.disableRow($row)
                })
                selectAllLogic.unselectAll()

            },
            error: function (error) {
                buttonLoadingState($this, false)
                addFlashMessage('danger', error.responseJSON.error)
            }
        })
    })
})

onmount('.js-number-contains', function () {
    var $number_contains = $(this),
        $country = $('.js-country-id'),
        $did_group = $('.js-did-group-id')

    var toggleMinCharsPattern = function () {
        if ($country.val() || $did_group.val()) {
            $number_contains.removeAttr('pattern')
        } else {
            $number_contains.attr('pattern', '.{0}|.{3,}')
        }
    }

    $country.on('change', toggleMinCharsPattern)
    $did_group.on('change', toggleMinCharsPattern)

    toggleMinCharsPattern()
})
