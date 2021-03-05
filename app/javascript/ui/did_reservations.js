import "../includes/utils.js"
import "../includes/select_all_logic.js"
import "../includes/sku_prices_in_table.js"
import { addFlashMessage, buttonLoadingState } from "../includes/utils"
import onmount from 'onmount'

var buildOrderItemPayload = function ($tr) {
    return {
        did_reservation_id: $tr.data('did-reservation-id'),
        sku_id: $tr.find('.js-row-sku-id').val(),
        in: true
    }
}

onmount('.js-order-did-reservation', function () {
    $(this).on('click', function () {
        var $this = $(this)
        var $tr = $this.closest('tr')
        var $skuParent = $('.js-sku-select-parent')
        if ($skuParent.length === 0) {
            $skuParent = null
        }
        var $td = $this.parent()
        var payload = {
            order: { items_attributes: [buildOrderItemPayload($skuParent || $tr)] }
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
                $td.empty()
                $td.append(link)
                addFlashMessage('success', ["Order was created successfully. ", link.clone()])
                if (!$skuParent) {
                    selectAllLogic.disableRow($tr)
                }
            },
            error: function (error) {
                buttonLoadingState($this, false)
                addFlashMessage('danger', error.responseJSON.error)
            }
        })
    })
})

onmount('.js-did-reservation-order-selected', function () {
    $(this).on('click', function () {
        var $this = $(this)
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

onmount('.js-remove-did-reservation', function () {
    $(this).on('click', function () {
        var $this = $(this)
        var $tr = $this.closest('tr')
        var $skuParent = $('.js-sku-select-parent')
        if ($skuParent.length === 0) {
            $skuParent = null
        }
        var $td = $this.parent()
        var reservationId = ($skuParent || $tr).data('did-reservation-id')
        var redirectOnSuccess = $this.data('redirect-on-success')
        buttonLoadingState($this, true)
        $.ajax({
            url: '/did_reservations/' + reservationId,
            method: 'DELETE',
            success: function () {
                buttonLoadingState($this, false)
                $td.empty().text('Removed')
                addFlashMessage('success', "Reservation was removed successfully.")
                if (!$skuParent) {
                    selectAllLogic.disableRow($tr)
                }
                if (redirectOnSuccess) {
                    Turbolinks.visit(redirectOnSuccess)
                }
            },
            error: function (error) {
                buttonLoadingState($this, false)
                addFlashMessage('danger', error.responseJSON.error)
            }
        })
    })
})

onmount('.js-did-reservation-reset', function () {
    $(this).on('click', function () {
        var $this = $(this)
        var $td = $this.closest('td')
        var payload = {
            did_reservation: { available_did_id: $this.data('available-did-id') }
        }
        buttonLoadingState($this, true)
        $.ajax({
            url: '/did_reservations',
            dataType: 'json',
            method: 'POST',
            data: payload,
            success: function (data) {
                buttonLoadingState($this, false)
                $td.find('.js-did-reservation-expire-at').text(
                    data.did_reservation.duration ?
                        (data.did_reservation.duration + ' left') :
                        'expired'
                )
            },
            error: function (error) {
                buttonLoadingState($this, false)
                addFlashMessage('danger', error.responseJSON.error)
            }
        })
    })
})
