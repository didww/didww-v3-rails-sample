form                = '.js-order-form '
subtotal_order      = form + '.js-capacity-order-subtotal'
action_remove       = '.js-cart-item-capacity-remove'
item_row            = form + 'tr[data-capacity-pool-id]'
nrc_column          = '.js-cart-item-capacity-nrc'
mrc_column          = '.js-cart-item-capacity-mrc'
prorate_cost_column = '.js-cart-item-capacity-prorate-sum'
qty_number          = '.js-cart-item-capacity-qty'
submit              = form + '.js-cart-submit-btn'

currency = (fl, currency) ->
  currency ||= '$'
  sign = if fl < 0 then '-' else ''
  sign + currency + (Math.round(Math.abs(fl) * 100) / 100).toFixed(2)

# Calculation

row_by_id = (id) ->
  $(item_row).filter('[data-capacity-pool-id="' + id + '"]')

row_id = (row) ->
  $(row).data('capacity-pool-id')

qty_based_pricings = ($row) ->
  qty = capacity_item_total_qty($row)
  qty_based_data = $row.data('capacity-pool-qty-based-pricings')
  for q, prices of qty_based_data
    if q > qty
      break
    price = qty_based_data[q]
  price

capacity_item_qty = ($row) ->
  (+$row.find(qty_number).val())

capacity_item_total_qty = ($row) ->
  capacity_item_qty($row) + (+$row.data('capacity-pool-current-capacity'))

capacity_item_prorate_price = ($row) ->
  monthly_price = +qty_based_pricings($row).mrc
  prorate_quotient = +$row.data('capacity-pool-prorate-quotient')
  monthly_price * prorate_quotient

capacity_item_setup_price = ($row) ->
  +qty_based_pricings($row).nrc

capacity_item_cost = ($row) ->
  qty = capacity_item_qty($row)
  prorate_price = capacity_item_prorate_price($row)
  setup_price = capacity_item_setup_price($row)
  qty * (prorate_price + setup_price)

# Rendering

show_capacity_order = ->
  $(item_row).each (i, row) ->
    show_capacity_pricing($(row))
  show_order_subtotal()

show_capacity_pricing = ($row) ->
  return unless $row.length
  pricing = qty_based_pricings($row)
  $row.find(nrc_column).text(currency(+pricing.nrc))
  $row.find(mrc_column).text(currency(+pricing.mrc))
  $row.find(prorate_cost_column).text(currency(capacity_item_prorate_price($row)))

show_order_subtotal = ->
  sum = 0
  $(item_row).each (i, row) ->
    sum += capacity_item_cost($(row))
  $(subtotal_order).text(currency(sum))
  $(submit).attr('disabled', $(item_row).length == 0)

# Binding

$.onmount form, ->
  $(qty_number).on 'input change', ->
    show_capacity_order()

  $(action_remove).click ->
    if confirm('Remove this item?')
      $(@).closest('tr').remove()
      show_capacity_order()

  show_capacity_order()
