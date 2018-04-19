import onMount from 'onmount'

const container      = '.js-balance ';
const reload_button  = `${container}.js-balance-reload `;
const details_div    = `${container} > div`;
const balance_detail = field => $(`${container}[data-balance-detail="${field}"] `);

onMount(container, () =>
    $(reload_button).click(() => {
        $(reload_button).attr('disabled', true);
        $(`${reload_button}i.fa`).addClass('fa-spin');
        return $.get({
            url: '/balance',
            dataType: 'json'}).done(json => {
            $(reload_button).attr('disabled', false)
            $(`${reload_button}i.fa`).removeClass('fa-spin')
            $(details_div).hide().fadeIn()
            return $.each(json, (key, val) => balance_detail(key).text(val))
        })
    })
)
