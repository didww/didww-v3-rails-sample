import onMount from 'onmount'

const form = '.js-dids-form ';
const tr_select = `${form}.js-trunk-select select`;
const tg_select = `${form}.js-trunk-group-select select`;


// DID can either be assigned to Trunk, or TrunkGroup.
onMount(form, () => {
    $(tr_select).change(() => $(tg_select).val(""));

    return $(tg_select).change(() => $(tr_select).val(""));
});
