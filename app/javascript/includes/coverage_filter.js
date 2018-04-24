import onMount from 'onmount'

const form = '.js-dynamic-cities '
const countryContainer = `${form}.js-country-select-container `
const regionContainer = `${form}.js-region-select-container `
const cityContainer = `${form}.js-city-select-container `
const countrySelect = `${countryContainer}select `
const regionSelect = `${regionContainer}select `
const citySelect = `${cityContainer}select `

const loadRegions = (filters) => {
  if (!filters) {
    // eslint-disable-next-line no-param-reassign
    filters = {
      'country.id': $(regionSelect).data('country-id'),
      'region.id': $(regionSelect).data('region-id')
    }
  }
  const query = $.param({ q: filters })
  $(regionContainer).show()
  $(regionSelect).val('').prop('disabled', true)
  // console.log(`loading regions with ${query}`)
  return $.get({
    url: '/dynamic_forms/regions/select',
    data: query
  }).done(html => $(regionSelect).replaceWith(html))
}

const loadCities = (filters) => {
  if (!filters) {
    // eslint-disable-next-line no-param-reassign
    filters = {
      'country.id': $(citySelect).data('country-id'),
      'region.id': $(citySelect).data('region-id'),
      'city.id': $(citySelect).data('city-id')
    }
  }
  if ($(form).hasClass('js-only-available')) {
    // eslint-disable-next-line no-param-reassign
    filters.is_available = true
  }
  const query = $.param({ q: filters })
  $(cityContainer).show()
  $(citySelect).val('').prop('disabled', true)
  // console.log(`loading cities with ${query}`)
  return $.get({
    url: '/dynamic_forms/cities/select',
    data: query
  }).done(html => $(citySelect).replaceWith(html))
}

const hideCities = () => {
  $(cityContainer).hide()
  return $(citySelect).val('')
}

const hideRegions = () => {
  $(regionContainer).hide()
  return $(regionSelect).val('')
}

// Fetch lists on change
onMount(countrySelect, () =>
  $(countrySelect).change(function () {
    if ($(this).val()) {
      if ($(countrySelect).find(':selected').data('has-regions')) {
        hideCities()
        return loadRegions({ 'country.id': $(this).val() })
      }
      hideRegions()
      return loadCities({ 'country.id': $(this).val() })
    }
    hideCities()
    return hideRegions()
  }))

onMount(regionSelect, () =>
  $(regionSelect).change(function () {
    if ($(this).val()) {
      return loadCities({ 'region.id': $(this).val() })
    }
    return hideCities()
  }))

// On first load, try to fetch region and city lists based on filters
onMount(form, () => {
  if ($(countrySelect).val()) {
    if ($(countrySelect).find(':selected').data('has-regions')) {
      loadRegions()
      if ($(regionSelect).data('region-id')) {
        return loadCities()
      }
    } else {
      return loadCities()
    }
  }
  return undefined
})
