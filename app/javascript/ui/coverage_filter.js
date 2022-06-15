import onmount from 'onmount'

const form = '.js-dynamic-cities '
const country_container = form + '.js-country-select-container '
const region_container = form + '.js-region-select-container '
const city_container = form + '.js-city-select-container '
const nanpa_prefix_container = form + '.js-nanpa-prefix-select-container '
const country_select = country_container + 'select '
const region_select = region_container + 'select '
const city_select = city_container + 'select '
const nanpa_prefix_select = nanpa_prefix_container + 'select '

const load_regions = function (filters) {
    if (!filters) {
        filters = {
            'country.id': $(region_select).data('country-id'),
            'region.id': $(region_select).data('region-id'),
            'nanpa_prefix.id': $(nanpa_prefix_select).data('nanpa-prefix-id')
        }
    }
    const query = $.param({ q: filters })
    $(region_container).show()
    $(region_select).val('').prop('disabled', true)
    // console.log('loading regions with ' + query)
    $.get({
        url: '/dynamic_forms/regions/select',
        data: query
    }).done(
        html => $(region_select).replaceWith(html)
    )
}

const load_cities = function (filters) {
    if (!filters) {
        filters = {
            'country.id': $(city_select).data('country-id'),
            'region.id': $(region_select).data('region-id'),
            'city.id': $(city_select).data('city-id'),
            'nanpa_prefix.id': $(nanpa_prefix_select).data('nanpa-prefix-id')
        }
    }
    if ($(form).hasClass('js-only-available')) {
        filters['is_available'] = true
    }
    const query = $.param({ q: filters })
    $(city_container).show()
    $(city_select).val('').prop('disabled', true)
    // console.log('loading cities with ' + query)
    $.get({
        url: '/dynamic_forms/cities/select',
        data: query
    }).done(
        html => $(city_select).replaceWith(html)
    )
}

const load_nanpa_prefixes = function (filters) {
    if (!filters) {
        filters = {
            'country.id': $(city_select).data('country-id'),
            'region.id': $(region_select).data('region-id'),
            'city.id': $(city_select).data('city-id'),
            'nanpa_prefix.id': $(nanpa_prefix_select).data('nanpa-prefix-id')
        }
    }
    const query = $.param({ q: filters })
    $(nanpa_prefix_container).show()
    $(nanpa_prefix_select).val('').prop('disabled', true)
//    console.log('loading nanpa prefixes with ' + query)
    $.get({
        url: '/dynamic_forms/nanpa_prefixes/select',
        data: query
    }).done(
        html => $(nanpa_prefix_select).replaceWith(html)
    )
}

const hide_cities = function () {
    $(city_container).hide()
    $(city_select).val('')
}

const hide_regions = function () {
    $(region_container).hide()
    $(region_select).val('')
}

const hide_nanpa_prefixes = function () {
    $(nanpa_prefix_container).hide()
    $(nanpa_prefix_select).val('')
}

// Fetch lists on change
onmount(country_select, () => $(country_select).change(function () {
    if ($(this).val()) {
        if ($(country_select).find(':selected').data('has-regions')) {
            hide_cities()
            if ($(country_select).find(':selected').data('has-nanpa-prefix')) {
                load_nanpa_prefixes({ 'country.id': $(this).val() })
            }
            load_regions({ 'country.id': $(this).val() })
        } else {
            hide_nanpa_prefixes()
            hide_regions()
            load_cities({ 'country.id': $(this).val() })
        }
    } else {
        hide_nanpa_prefixes()
        hide_cities()
        hide_regions()
    }
}))

onmount(region_select, () => $(region_select).change(function () {
    if ($(this).val()) {
        load_cities({ 'region.id': $(this).val() })

        if ($(country_select).find(':selected').data('has-nanpa-prefix')) {
            load_nanpa_prefixes({ 'country.id': $(country_select).find(':selected').val(), 'region.id': $(this).val() })
        }
    } else {
        hide_cities()
        load_nanpa_prefixes({ 'country.id': $(country_select).find(':selected').val() })
    }
}))

onmount(region_select, () => $(region_select).change(function () {
    if ($(this).val()) {
        load_cities({ 'region.id': $(this).val() })

        if ($(country_select).find(':selected').data('has-nanpa-prefix')) {
            load_nanpa_prefixes({ 'country.id': $(country_select).find(':selected').val(), 'region.id': $(this).val() })
        }
    } else {
        hide_cities()
        load_nanpa_prefixes({ 'country.id': $(country_select).find(':selected').val() })
    }
}))

// On first load, try to fetch region and city lists based on filters
onmount(form, function() {
    if ($(country_select).val()) {
        if ($(country_select).find(':selected').data('has-regions')) {
            load_regions()

            if ($(country_select).find(':selected').data('has-nanpa-prefix')) {
                load_nanpa_prefixes()
            }

            if ($(region_select).data('region-id')) {
                load_cities()
            }
        } else {
            load_cities()
        }
    }
})

