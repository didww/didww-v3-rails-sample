form = '.js-dynamic-cities '
country_container = form + '.js-country-select-container '
region_container  = form + '.js-region-select-container '
city_container    = form + '.js-city-select-container '
country_select    = country_container + 'select '
region_select     = region_container + 'select '
city_select       = city_container + 'select '

load_regions = (filters) ->
  filters ||=
    'country.id': $(region_select).data('country-id')
    'region.id': $(region_select).data('region-id')
  query = $.param q: filters
  $(region_container).show()
  $(region_select).val('').prop('disabled', true)
  console.log('loading regions with ' + query)
  $.get
    url: '/dynamic_forms/regions/select'
    data: query
  .done (html) ->
    $(region_select).replaceWith(html)

load_cities = (filters) ->
  filters ||=
    'country.id': $(city_select).data('country-id')
    'region.id': $(city_select).data('region-id')
    'city.id': $(city_select).data('city-id')
  filters['is_available'] = true if $(form).hasClass('js-only-available')
  query = $.param q: filters
  $(city_container).show()
  $(city_select).val('').prop('disabled', true)
  console.log('loading cities with ' + query)
  $.get
    url: '/dynamic_forms/cities/select'
    data: query
  .done (html) ->
    $(city_select).replaceWith(html)

hide_cities = ->
  $(city_container).hide()
  $(city_select).val('')

hide_regions = ->
  $(region_container).hide()
  $(region_select).val('')

# Fetch lists on change
$.onmount country_select, ->
  $(country_select).change ->
    if $(@).val()
      if $(country_select).find(':selected').data('has-regions')
        hide_cities()
        load_regions { 'country.id': $(@).val() }
      else
        hide_regions()
        load_cities { 'country.id': $(@).val() }
    else
      hide_cities()
      hide_regions()

$.onmount region_select, ->
  $(region_select).change ->
    if $(@).val()
      load_cities { 'region.id': $(@).val() }
    else
      hide_cities()

# On first load, try to fetch region and city lists based on filters
$.onmount form, ->
  if $(country_select).val()
    if $(country_select).find(':selected').data('has-regions')
      load_regions()
      if $(region_select).data('region-id')
        load_cities()
    else
      load_cities()
