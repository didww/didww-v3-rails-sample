import onmount from "onmount"

const form = ".js-trunks-form "
const trunk_group_select = `${form}.js-trunk-group-select select`
const trunk_group_fields = "#trunk_priority, #trunk_weight, #trunk_ringing_timeout"

const toggle_group_fields = () => $(trunk_group_fields).prop("disabled", !$(trunk_group_select).val())

onmount(form, () => {
    $(trunk_group_select).change(() => toggle_group_fields()).change()

    // Expand all panes containing fields with error
    $(".js-collapsible-panel").each(function () {
        if ($(this).find(".has-error").length > 0) {
            $(this).find("div.panel-collapse").collapse("show")
        }
    })
})
