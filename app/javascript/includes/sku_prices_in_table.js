import onmount from "onmount"
import { selectedOptionFor } from "./utils"

const showSkuPrices = function (skuSelect) {
    const $skuSelect = $(skuSelect)
    const $tr = $skuSelect.closest($skuSelect.data("parent-selector") || "tr")
    const selectedOption = selectedOptionFor($skuSelect)
    $tr.find(".js-row-sku-nrc").text(selectedOption.data("nrc"))
    $tr.find(".js-row-sku-mrc").text(selectedOption.data("mrc"))
}

onmount(".js-row-sku-id", function () {
    showSkuPrices(this)
    $(this).on("change", function () {
        showSkuPrices(this)
    })
})
