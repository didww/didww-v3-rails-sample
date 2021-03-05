import { addFlashMessage, buttonLoadingState } from "../includes/utils.js"
import "../includes/select_all_logic.js"
import "../includes/sku_prices_in_table.js"

import onmount from "onmount"

const buildOrderItemPayload = function ($tr) {
    return {
        did_reservation_id: $tr.data("did-reservation-id"),
        sku_id: $tr.find(".js-row-sku-id").val(),
        in: true
    }
}

onmount(".js-order-did-reservation", function () {
    $(this).on("click", function () {
        const $this = $(this)
        const $tr = $this.closest("tr")
        let $skuParent = $(".js-sku-select-parent")
        if ($skuParent.length === 0) {
            $skuParent = null
        }
        const $td = $this.parent()
        const payload = {
            order: { items_attributes: [buildOrderItemPayload($skuParent || $tr)] }
        }
        buttonLoadingState($this, true)
        $.ajax({
            url: "/orders",
            method: "POST",
            dataType: "json",
            data: payload,
            success(data) {
                buttonLoadingState($this, false)
                const link = $("<a>", { href: `/orders/${data.order.id}` }).text("See Order")
                $td.empty()
                $td.append(link)
                addFlashMessage("success", ["Order was created successfully. ", link.clone()])
                if (!$skuParent) {
                    selectAllLogic.disableRow($tr)
                }
            },
            error(error) {
                buttonLoadingState($this, false)
                addFlashMessage("danger", error.responseJSON.error)
            }
        })
    })
})

onmount(".js-did-reservation-order-selected", function () {
    $(this).on("click", function () {
        const $this = $(this)
        const $selectedRows = $("tbody > tr.selected").toArray()
        const payload = {
            order: {
                items_attributes: $selectedRows.map((tr) => buildOrderItemPayload($(tr)))
            }
        }
        buttonLoadingState($this, true)
        $.ajax({
            url: "/orders",
            method: "POST",
            dataType: "json",
            data: payload,
            success(data) {
                buttonLoadingState($this, false)
                const link = $("<a>", { href: `/orders/${data.order.id}` }).text("See Order")
                addFlashMessage("success", ["Order was created successfully. ", link])
                $selectedRows.forEach((row) => {
                    const $row = $(row)
                    $row.find("> td:last-child").empty().append(link.clone())
                    selectAllLogic.disableRow($row)
                })
                selectAllLogic.unselectAll()
            },
            error(error) {
                buttonLoadingState($this, false)
                addFlashMessage("danger", error.responseJSON.error)
            }
        })
    })
})

onmount(".js-remove-did-reservation", function () {
    $(this).on("click", function () {
        const $this = $(this)
        const $tr = $this.closest("tr")
        let $skuParent = $(".js-sku-select-parent")
        if ($skuParent.length === 0) {
            $skuParent = null
        }
        const $td = $this.parent()
        const reservationId = ($skuParent || $tr).data("did-reservation-id")
        const redirectOnSuccess = $this.data("redirect-on-success")
        buttonLoadingState($this, true)
        $.ajax({
            url: `/did_reservations/${reservationId}`,
            method: "DELETE",
            success() {
                buttonLoadingState($this, false)
                $td.empty().text("Removed")
                addFlashMessage("success", "Reservation was removed successfully.")
                if (!$skuParent) {
                    selectAllLogic.disableRow($tr)
                }
                if (redirectOnSuccess) {
                    Turbolinks.visit(redirectOnSuccess)
                }
            },
            error(error) {
                buttonLoadingState($this, false)
                addFlashMessage("danger", error.responseJSON.error)
            }
        })
    })
})

onmount(".js-did-reservation-reset", function () {
    $(this).on("click", function () {
        const $this = $(this)
        const $td = $this.closest("td")
        const payload = {
            did_reservation: { available_did_id: $this.data("available-did-id") }
        }
        buttonLoadingState($this, true)
        $.ajax({
            url: "/did_reservations",
            dataType: "json",
            method: "POST",
            data: payload,
            success(data) {
                buttonLoadingState($this, false)
                $td.find(".js-did-reservation-expire-at").text(
                    data.did_reservation.duration
                        ? (`${data.did_reservation.duration} left`)
                        : "expired"
                )
            },
            error(error) {
                buttonLoadingState($this, false)
                addFlashMessage("danger", error.responseJSON.error)
            }
        })
    })
})
