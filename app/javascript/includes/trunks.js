import onMount from 'onmount'

const form = '.js-trunks-form '
const trunkGroupSelect = `${form}.js-trunk-group-select select`
const trunkGroupFields = '#trunk_priority, #trunk_weight, #trunk_ringing_timeout'

const toggleGroupFields = () => $(trunkGroupFields).prop('disabled', !$(trunkGroupSelect).val())

onMount(form, () => {
  $(trunkGroupSelect).change(() => toggleGroupFields()).change()

  // Expand all panes containing fields with error
  return $('.js-collapsible-panel').each(function () {
    if ($(this).find('.has-error').length > 0) {
      return $(this).find('div.panel-collapse').collapse('show')
    }
    return undefined
  })
})
