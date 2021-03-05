import { addFlashMessage, buttonLoadingState } from "../includes/utils.js"
import selectAllLogic from "../includes/select_all_logic.js"
import "../includes/sku_prices_in_table.js"

import onmount from "onmount"

const buildOrderItemPayload = function ($tr) {
    return {
        available_did_id: $tr.data("available-did-id"),
        sku_id: $tr.find(".js-available-did-sku-select-wrapper > select").val(),
        in: true
    }
}

onmount(".js-available-dids-refresh", function () {
    const $this = $(this)
    $this.on("click", () => {
        buttonLoadingState($this, true)
        // location.reload(true)
        Turbolinks.visit(location.toString(), { action: "replace" })
    })
})

onmount(".js-reserve-did-modal-save", function () {
    $(this).on("click", function () {
        const $this = $(this)
        const $modal = $(".js-reserve-did-modal")
        const availableDidId = $modal.find("input[name=\"available_did_id\"]").val()
        const $tr = $(".js-table-available-dids").find(`tr[data-available-did-id="${availableDidId}"]`)
        const $td = $tr.find("> td:last-child")
        const payload = {
            available_did_id: availableDidId,
            description: $modal.find("input[name=\"description\"]").val()
        }
        buttonLoadingState($this, true)
        $.ajax({
            url: "/did_reservations",
            dataType: "json",
            method: "POST",
            data: { did_reservation: payload },
            success(data) {
                buttonLoadingState($this, false)
                const link = $("<a>", { href: `/did_reservations/${data.did_reservation.id}` }).text("See Reservation")
                $td.empty()
                $td.append(link)
                $modal.modal("hide")
                addFlashMessage("success", ["Reservation was created successfully. ", link.clone()])
                selectAllLogic.disableRow($tr)
            },
            error(error) {
                buttonLoadingState($this, false)
                $modal.modal("hide")
                addFlashMessage("danger", error.responseJSON.error)
            }
        })
    })
})

onmount(".js-reserve-available-did", function () {
    $(this).on("click", function () {
        const $this = $(this)
        const $tr = $this.closest("tr")
        const $modal = $(".js-reserve-did-modal")
        $modal.find("input[name=\"description\"]").val("")
        $modal.find("input[name=\"available_did_id\"]").val($tr.data("available-did-id"))
        $modal.modal("show")
    })
})

onmount(".js-order-available-did", function () {
    $(this).on("click", function () {
        const $this = $(this)
        const $tr = $this.closest("tr")
        const $td = $this.closest("td")
        const payload = {
            order: { items_attributes: [buildOrderItemPayload($tr)] }
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
                selectAllLogic.disableRow($tr)
            },
            error(error) {
                buttonLoadingState($this, false)
                addFlashMessage("danger", error.responseJSON.error)
            }
        })
    })
})

onmount(".js-available-did-order-selected", function () {
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

onmount(".js-number-contains", function () {
    const $number_contains = $(this)
    const $country = $(".js-country-id")
    const $did_group = $(".js-did-group-id")

    const toggleMinCharsPattern = function () {
        if ($country.val() || $did_group.val()) {
            $number_contains.removeAttr("pattern")
        } else {
            $number_contains.attr("pattern", ".{0}|.{3,}")
        }
    }

    $country.on("change", toggleMinCharsPattern)
    $did_group.on("change", toggleMinCharsPattern)

    toggleMinCharsPattern()
})
