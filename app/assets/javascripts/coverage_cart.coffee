form            = '.js-cart-form '
subtotal_cart   = form + '.js-cart-subtotal'
subtotal_order  = form + '.js-order-subtotal'
submit          = form + '.js-cart-submit-btn'
actions         = form + '.js-cart-actions '
action_clear    = actions + '.js-cart-clear-btn'
action_list     = actions + '.js-cart-list-btn'
action_remove   = '.js-cart-remove-item'
item_row        = form + 'tr[data-did-group-id]'
capacity_select = '.js-cart-item-sku-id '
qty_number      = '.js-cart-item-qty '
item_checkbox   = '.js-cart-item-in '
nrc_column      = '.js-cart-item-nrc'
mrc_column      = '.js-cart-item-mrc'

currency = (fl, currency) ->
  currency ||= '$'
  sign = if fl < 0 then '-' else ''
  sign + currency + (Math.round(Math.abs(fl) * 100) / 100).toFixed(2)

row_by_id = (id) ->
  $(item_row).filter('[data-did-group-id="' + id + '"]')

row_id = (row) ->
  $(row).data('did-group-id')

show_capacity_pricing = ($row) ->
  return unless $row.length
  pricing = $row.find(capacity_select).find(':selected').data()
  $row.find(nrc_column).text(currency(pricing['nrc']))
  $row.find(mrc_column).text(currency(pricing['mrc']))

update_cart_item = (did_group_id) ->
  row          = row_by_id(did_group_id)
  sku_option   = row.find(capacity_select).find(':selected')
  sku_id       = sku_option.val()
  nrc_price    = sku_option.data('nrc')
  mrc_price    = sku_option.data('mrc')
  qty          = row.find(qty_number).val()
  added        = row.find(item_checkbox).is(':checked')
  if added
    add_cart_item did_group_id,
      sku_id: sku_id,
      np: +nrc_price,
      mp: +mrc_price,
      qty: +qty
  else
    remove_cart_item did_group_id

add_cart_item = (did_group_id, props) ->
  change_cart (cart) ->
    cart[did_group_id] = props

remove_cart_item = (did_group_id) ->
  change_cart (cart) ->
    delete cart[did_group_id]

get_cart = ->
  Cookies.getJSON('cart') || {}

change_cart = (func) ->
  cart = get_cart()
  func(cart)
  Cookies.set('cart', cart)
  console.log Object.keys(cart).length
  display_cart()

clear_cart = ->
  Cookies.set('cart', {})
  display_cart()

display_cart = ->
  $(item_row).each (i, row) ->
    display_cart_item row_id(row)
  display_cart_subtotal()

display_cart_item = (id, props) ->
  props ||= get_cart()[id]
  row   = row_by_id(id)
  if props
    row.find(capacity_select).val(props['sku_id'])
    row.find(qty_number).val(props['qty'])
    row.find(item_checkbox).prop('checked', true)
  else
    row.find(item_checkbox).prop('checked', false)
  show_capacity_pricing(row)

display_cart_subtotal = ->
  items_count = dids_count = qty = np = mp = 0
  $.each get_cart(), (id, props) ->
    items_count += 1
    qty = props['qty']
    dids_count += qty
    np += qty * props['np']
    mp += qty * props['mp']
  $(subtotal_cart).html(
    '<strong>' + items_count + '</strong> items, ' +
    '<strong>' + dids_count + '</strong> DIDs, ' +
    '<strong>' + currency(np + mp) + '</strong> total'
  )
  $(subtotal_order).html('<strong>' + currency(np + mp) + '</strong>')
  $(actions).toggle(items_count > 0)
  $(submit).attr('disabled', items_count == 0)

$.onmount form, ->
  console.log 'mounted FORM'
  $(capacity_select + ', ' + item_checkbox).on 'change', ->
    update_cart_item row_id($(@).closest('tr'))

  $(qty_number).on 'input change', ->
    update_cart_item row_id($(@).closest('tr'))

  $(action_list).click ->
    did_group_ids = []
    $.each get_cart(), (id) ->
      did_group_ids.push id
    window.location.search = $.param(q: { id: did_group_ids })

  $(action_remove).click ->
    if confirm('Remove this item?')
      id = row_id($(@).closest('tr'))
      remove_cart_item(id)
      row_by_id(id).remove()

  $(action_clear).click ->
    clear_cart() if confirm('Remove all selected items?')

  $(form).submit (e)->
    $(form).find('[name^="order[items_attributes]"]').attr('disabled', true)
    $.each get_cart(), (id, props) ->
      $('<input type="hidden">').attr('name', 'order[items_attributes][][did_group_id]').attr('value', id).appendTo(form)
      $('<input type="hidden">').attr('name', 'order[items_attributes][][qty]').attr('value', props['qty']).appendTo(form)
      $('<input type="hidden">').attr('name', 'order[items_attributes][][sku_id]').attr('value', props['sku_id']).appendTo(form)
      $('<input type="hidden">').attr('name', 'order[items_attributes][][in]').attr('value', true).appendTo(form)

  display_cart()
