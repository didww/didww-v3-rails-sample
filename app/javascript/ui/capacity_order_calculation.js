import onmount from "onmount"

const form = ".js-order-form "
const subtotal_order = `${form}.js-capacity-order-subtotal`
const action_remove = ".js-cart-item-capacity-remove"
const item_row = `${form}tr[data-capacity-pool-id]`
const nrc_column = ".js-cart-item-capacity-nrc"
const mrc_column = ".js-cart-item-capacity-mrc"
const prorate_cost_column = ".js-cart-item-capacity-prorate-sum"
const qty_number = ".js-cart-item-capacity-qty"
const submit = `${form}.js-cart-submit-btn`

const currency = function (fl, currency) {
    if (!currency) currency = "$"

    const sign = fl < 0 ? "-" : ""
    return sign + currency + (Math.round(Math.abs(fl) * 100) / 100).toFixed(2)
}

// Calculation

const row_by_id = (id) => $(item_row).filter(`[data-capacity-pool-id="${id}"]`)

const row_id = (row) => $(row).data("capacity-pool-id")

const qty_based_pricings = function ($row) {
    let price = null
    const qty = capacity_item_total_qty($row)
    const qty_based_data = $row.data("capacity-pool-qty-based-pricings")
    for (const q in qty_based_data) {
        if (q > qty) {
            break
        }
        price = qty_based_data[q]
    }
    return price
}

const capacity_item_qty = ($row) => +$row.find(qty_number).val()

const capacity_item_total_qty = ($row) => capacity_item_qty($row) + (+$row.data("capacity-pool-current-capacity"))

const capacity_item_prorate_price = function ($row) {
    const monthly_price = +qty_based_pricings($row).mrc
    const prorate_quotient = +$row.data("capacity-pool-prorate-quotient")
    return monthly_price * prorate_quotient
}

const capacity_item_setup_price = ($row) => +qty_based_pricings($row).nrc

const capacity_item_cost = function ($row) {
    const qty = capacity_item_qty($row)
    const prorate_price = capacity_item_prorate_price($row)
    const setup_price = capacity_item_setup_price($row)
    return qty * (prorate_price + setup_price)
}

// Rendering

const show_capacity_order = function () {
    $(item_row).each((i, row) => show_capacity_pricing($(row)))
    show_order_subtotal()
}

const show_capacity_pricing = function ($row) {
    if (!$row.length) {
        return
    }
    const pricing = qty_based_pricings($row)
    $row.find(nrc_column).text(currency(+pricing.nrc))
    $row.find(mrc_column).text(currency(+pricing.mrc))
    $row.find(prorate_cost_column).text(currency(capacity_item_prorate_price($row)))
}

const show_order_subtotal = function () {
    let sum = 0
    $(item_row).each((i, row) => sum += capacity_item_cost($(row)))
    $(subtotal_order).text(currency(sum))
    $(submit).attr("disabled", $(item_row).length === 0)
}

// Binding

onmount(form, () => {
    $(qty_number).on("input change", () => show_capacity_order())

    $(action_remove).click(function () {
        if (confirm("Remove this item?")) {
            $(this).closest("tr").remove()
            show_capacity_order()
        }
    })

    show_capacity_order()
})
