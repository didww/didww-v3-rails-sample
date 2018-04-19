import onMount from 'onmount'

const form = '.js-dids-form '
const trSelect = `${form}.js-trunk-select select`
const tgSelect = `${form}.js-trunk-group-select select`


// DID can either be assigned to Trunk, or TrunkGroup.
onMount(form, () => {
  $(trSelect).change(() => $(tgSelect).val(''))

  return $(tgSelect).change(() => $(trSelect).val(''))
})
