import onMount from 'onmount'

const form = '.js-dynamic-cities ';
const country_container = `${form}.js-country-select-container `;
const region_container  = `${form}.js-region-select-container `;
const city_container    = `${form}.js-city-select-container `;
const country_select    = `${country_container}select `;
const region_select     = `${region_container}select `;
const city_select       = `${city_container}select `;

const load_regions = filters => {
    if (!filters) { filters =  {
        'country.id': $(region_select).data('country-id'),
        'region.id': $(region_select).data('region-id')
    }; }
    const query = $.param({q: filters});
    $(region_container).show();
    $(region_select).val('').prop('disabled', true);
    console.log(`loading regions with ${query}`);
    return $.get({
        url: '/dynamic_forms/regions/select',
        data: query}).done(html => $(region_select).replaceWith(html));
};

const load_cities = filters => {
    if (!filters) { filters =  {
        'country.id': $(city_select).data('country-id'),
        'region.id': $(city_select).data('region-id'),
        'city.id': $(city_select).data('city-id')
    }; }
    if ($(form).hasClass('js-only-available')) { filters['is_available'] = true; }
    const query = $.param({q: filters});
    $(city_container).show();
    $(city_select).val('').prop('disabled', true);
    console.log(`loading cities with ${query}`);
    return $.get({
        url: '/dynamic_forms/cities/select',
        data: query}).done(html => $(city_select).replaceWith(html));
};

const hide_cities = () => {
    $(city_container).hide();
    return $(city_select).val('');
};

const hide_regions = () => {
    $(region_container).hide();
    return $(region_select).val('');
};

// Fetch lists on change
onMount(country_select, () =>
    $(country_select).change(function() {
        if ($(this).val()) {
            if ($(country_select).find(':selected').data('has-regions')) {
                hide_cities();
                return load_regions({ 'country.id': $(this).val() });
            } else {
                hide_regions();
                return load_cities({ 'country.id': $(this).val() });
            }
        } else {
            hide_cities();
            return hide_regions();
        }
    })
);

onMount(region_select, () =>
    $(region_select).change(function() {
        if ($(this).val()) {
            return load_cities({ 'region.id': $(this).val() });
        } else {
            return hide_cities();
        }
    })
);

// On first load, try to fetch region and city lists based on filters
onMount(form, () => {
    if ($(country_select).val()) {
        if ($(country_select).find(':selected').data('has-regions')) {
            load_regions();
            if ($(region_select).data('region-id')) {
                return load_cities();
            }
        } else {
            return load_cities();
        }
    }
});
