import onMount from 'onmount'
import Cookies from 'js-cookie/src/js.cookie'

const form            = '.js-cart-form ';
const subtotal_cart   = `${form}.js-cart-subtotal`;
const subtotal_order  = `${form}.js-order-subtotal`;
const submit          = `${form}.js-cart-submit-btn`;
const actions         = `${form}.js-cart-actions `;
const action_clear    = `${actions}.js-cart-clear-btn`;
const action_list     = `${actions}.js-cart-list-btn`;
const action_remove   = '.js-cart-remove-item';
const item_row        = `${form}tr[data-did-group-id]`;
const capacity_select = '.js-cart-item-sku-id ';
const qty_number      = '.js-cart-item-qty ';
const item_checkbox   = '.js-cart-item-in ';
const nrc_column      = '.js-cart-item-nrc';
const mrc_column      = '.js-cart-item-mrc';

const currency = (fl, currency) => {
    if (!currency) { currency = '$'; }
    const sign = fl < 0 ? '-' : '';
    return sign + currency + (Math.round(Math.abs(fl) * 100) / 100).toFixed(2);
};

const row_by_id = id => $(item_row).filter(`[data-did-group-id="${id}"]`);

const row_id = row => $(row).data('did-group-id');

const show_capacity_pricing = $row => {
    if (!$row.length) { return; }
    const pricing = $row.find(capacity_select).find(':selected').data();
    $row.find(nrc_column).text(currency(pricing['nrc']));
    return $row.find(mrc_column).text(currency(pricing['mrc']));
};

const update_cart_item = did_group_id => {
    const row          = row_by_id(did_group_id);
    const sku_option   = row.find(capacity_select).find(':selected');
    const sku_id       = sku_option.val();
    const nrc_price    = sku_option.data('nrc');
    const mrc_price    = sku_option.data('mrc');
    const qty          = row.find(qty_number).val();
    const added        = row.find(item_checkbox).is(':checked');
    if (added) {
        return add_cart_item(did_group_id, {
                sku_id,
                np: +nrc_price,
                mp: +mrc_price,
                qty: +qty
            }
        );
    } else {
        return remove_cart_item(did_group_id);
    }
};

var add_cart_item = (did_group_id, props) =>
    change_cart(cart => cart[did_group_id] = props)
;

var remove_cart_item = did_group_id =>
    change_cart(cart => delete cart[did_group_id])
;

const get_cart = () => Cookies.getJSON('cart') || {};

var change_cart = func => {
    const cart = get_cart();
    func(cart);
    Cookies.set('cart', cart);
    console.log(Object.keys(cart).length);
    return display_cart();
};

const clear_cart = () => {
    Cookies.set('cart', {});
    return display_cart();
};

var display_cart = () => {
    $(item_row).each((i, row) => display_cart_item(row_id(row)));
    return display_cart_subtotal();
};

var display_cart_item = (id, props) => {
    if (!props) { props = get_cart()[id]; }
    const row   = row_by_id(id);
    if (props) {
        row.find(capacity_select).val(props['sku_id']);
        row.find(qty_number).val(props['qty']);
        row.find(item_checkbox).prop('checked', true);
    } else {
        row.find(item_checkbox).prop('checked', false);
    }
    return show_capacity_pricing(row);
};

var display_cart_subtotal = () => {
    let dids_count;
    let mp;
    let np;
    let qty;
    let items_count = (dids_count = (qty = (np = (mp = 0))));
    $.each(get_cart(), (id, props) => {
        items_count += 1;
        qty = props['qty'];
        dids_count += qty;
        np += qty * props['np'];
        return mp += qty * props['mp'];
    });
    $(subtotal_cart).html(
        `${`<strong>${items_count}</strong> items, `}<strong>${dids_count}</strong> DIDs, <strong>${currency(np + mp)}</strong> total`
    );
    $(subtotal_order).html(`<strong>${currency(np + mp)}</strong>`);
    $(actions).toggle(items_count > 0);
    return $(submit).attr('disabled', items_count === 0);
};

onMount(form, () => {
    console.log('mounted FORM');
    $(`${capacity_select}, ${item_checkbox}`).on('change', function() {
        return update_cart_item(row_id($(this).closest('tr')));
    });

    $(qty_number).on('input change', function() {
        return update_cart_item(row_id($(this).closest('tr')));
    });

    $(action_list).click(() => {
        const did_group_ids = [];
        $.each(get_cart(), id => did_group_ids.push(id));
        return window.location.search = $.param({q: { id: did_group_ids }});
    });

    $(action_remove).click(function() {
        if (confirm('Remove this item?')) {
            const id = row_id($(this).closest('tr'));
            remove_cart_item(id);
            return row_by_id(id).remove();
        }
    });

    $(action_clear).click(() => {
        if (confirm('Remove all selected items?')) { return clear_cart(); }
    });

    $(form).submit(e => {
        $(form).find('[name^="order[items_attributes]"]').attr('disabled', true);
        return $.each(get_cart(), (id, props) => {
            $('<input type="hidden">').attr('name', 'order[items_attributes][][did_group_id]').attr('value', id).appendTo(form);
            $('<input type="hidden">').attr('name', 'order[items_attributes][][qty]').attr('value', props['qty']).appendTo(form);
            $('<input type="hidden">').attr('name', 'order[items_attributes][][sku_id]').attr('value', props['sku_id']).appendTo(form);
            return $('<input type="hidden">').attr('name', 'order[items_attributes][][in]').attr('value', true).appendTo(form);
        });
    });

    return display_cart();
});
