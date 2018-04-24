import onMount from 'onmount'
import Cookies from 'js-cookie/src/js.cookie'

const form = '.js-cart-form '
const subtotalCart = `${form}.js-cart-subtotal`
const subtotalOrder = `${form}.js-order-subtotal`
const submit = `${form}.js-cart-submit-btn`
const actions = `${form}.js-cart-actions `
const actionClear = `${actions}.js-cart-clear-btn`
const actionList = `${actions}.js-cart-list-btn`
const actionRemove = '.js-cart-remove-item'
const itemRow = `${form}tr[data-did-group-id]`
const capacitySelect = '.js-cart-item-sku-id '
const qtyNumber = '.js-cart-item-qty '
const itemCheckbox = '.js-cart-item-in '
const nrcColumn = '.js-cart-item-nrc'
const mrcColumn = '.js-cart-item-mrc'

const currency = (fl, curr = '$') => {
  const sign = fl < 0 ? '-' : ''
  return sign + curr + (Math.round(Math.abs(fl) * 100) / 100).toFixed(2)
}

const rowById = id => $(itemRow).filter(`[data-did-group-id="${id}"]`)

const rowId = row => $(row).data('did-group-id')

const showCapacityPricing = ($row) => {
  if (!$row.length) {
    return undefined
  }
  const pricing = $row.find(capacitySelect).find(':selected').data()
  $row.find(nrcColumn).text(currency(pricing.nrc))
  return $row.find(mrcColumn).text(currency(pricing.mrc))
}

const getCart = () => Cookies.getJSON('cart') || {}

const displayCartItem = (id, props = getCart()[id]) => {
  const row = rowById(id)
  if (props) {
    row.find(capacitySelect).val(props.skuId)
    row.find(qtyNumber).val(props.qty)
    row.find(itemCheckbox).prop('checked', true)
  } else {
    row.find(itemCheckbox).prop('checked', false)
  }
  return showCapacityPricing(row)
}

const displayCartSubtotal = () => {
  let didsCount = 0
  let mp = 0
  let np = 0
  let qty = 0
  let itemsCount = 0
  $.each(getCart(), (id, props) => {
    itemsCount += 1;
    ({ qty } = props)
    didsCount += qty
    np += qty * props.np
    mp += qty * props.mp
    return mp
  })
  $(subtotalCart).html(`<strong>${itemsCount}</strong> items, <strong>${didsCount}</strong> DIDs, <strong>${currency(np + mp)}</strong> total`)
  $(subtotalOrder).html(`<strong>${currency(np + mp)}</strong>`)
  $(actions).toggle(itemsCount > 0)
  return $(submit).attr('disabled', itemsCount === 0)
}

const displayCart = () => {
  $(itemRow).each((i, row) => displayCartItem(rowId(row)))
  return displayCartSubtotal()
}

const changeCart = (func) => {
  const cart = func(getCart())
  Cookies.set('cart', cart)
  // console.log(Object.keys(cart).length)
  return displayCart()
}

const addCartItem = (didGroupId, props) => changeCart((cart) => {
  const c = cart
  c[didGroupId] = props
  return c
})


const removeCartItem = didGroupId => changeCart((cart) => {
  const c = cart
  delete c[didGroupId]
  return c
})

const clearCart = () => {
  Cookies.set('cart', {})
  return displayCart()
}

const updateCartItem = (didGroupId) => {
  const row = rowById(didGroupId)
  const skuOption = row.find(capacitySelect).find(':selected')
  const skuId = skuOption.val()
  const nrcPrice = skuOption.data('nrc')
  const mrcPrice = skuOption.data('mrc')
  const qty = row.find(qtyNumber).val()
  const added = row.find(itemCheckbox).is(':checked')
  if (added) {
    return addCartItem(didGroupId, {
      skuId,
      np: +nrcPrice,
      mp: +mrcPrice,
      qty: +qty
    })
  }
  return removeCartItem(didGroupId)
}

onMount(form, () => {
  // console.log('mounted FORM')
  $(`${capacitySelect}, ${itemCheckbox}`).on('change', function () {
    return updateCartItem(rowId($(this).closest('tr')))
  })

  $(qtyNumber).on('input change', function () {
    return updateCartItem(rowId($(this).closest('tr')))
  })

  $(actionList).click(() => {
    const didDroupIds = []
    $.each(getCart(), id => didDroupIds.push(id))
    window.location.search = $.param({ q: { id: didDroupIds } })
    return window.location.search
  })

  $(actionRemove).click(function () {
    if (window.confirm('Remove this item?')) {
      const id = rowId($(this).closest('tr'))
      removeCartItem(id)
      return rowById(id).remove()
    }
    return undefined
  })

  $(actionClear).click(() => {
    if (window.confirm('Remove all selected items?')) {
      return clearCart()
    }
    return undefined
  })

  $(form).submit(() => {
    $(form).find('[name^="order[items_attributes]"]').attr('disabled', true)
    return $.each(getCart(), (id, props) => {
      $('<input type="hidden">').attr('name', 'order[items_attributes][][did_group_id]').attr('value', id).appendTo(form)
      $('<input type="hidden">').attr('name', 'order[items_attributes][][qty]').attr('value', props.qty).appendTo(form)
      $('<input type="hidden">').attr('name', 'order[items_attributes][][sku_id]').attr('value', props.skuId).appendTo(form)
      return $('<input type="hidden">').attr('name', 'order[items_attributes][][in]').attr('value', true).appendTo(form)
    })
  })

  return displayCart()
})
