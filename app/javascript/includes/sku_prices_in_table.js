import { selectedOptionFor } from "./utils"
import onmount from 'onmount'

let showSkuPrices = function (skuSelect) {
    let $skuSelect = $(skuSelect)
    let $tr = $skuSelect.closest($skuSelect.data('parent-selector') || 'tr')
    let selectedOption = selectedOptionFor($skuSelect)
    $tr.find('.js-row-sku-nrc').text(selectedOption.data('nrc'))
    $tr.find('.js-row-sku-mrc').text(selectedOption.data('mrc'))
}

onmount('.js-row-sku-id', function () {
    showSkuPrices(this)
    $(this).on('change', function () {
        showSkuPrices(this)
    })
})

