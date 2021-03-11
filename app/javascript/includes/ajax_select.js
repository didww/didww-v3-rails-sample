import queryString from 'query-string'
import createElement from './create_element'

const AJAX_SELECT_SELECTOR = '.ajax-select'

function buildLoadingOptions (select) {
    const label = select.data('loading') || '--- Loading... ---'
    return createElement('option', { value: '', label: label })
}

function buildEmptySelectOption (select) {
    const label = select.data('empty-selection') || '--- Choose an option ---'
    return createElement('option', { value: '', label: label })
}

function buildNoDataOption (select) {
    const label = select.data('nothing') || '--- No data ---'
    return createElement('option', { value: '', label: label })
}

function buildOption(option) {
    return createElement('option', { value: option.id }, option.text)
}

function gatherDependentParams(select) {
    const dependencies = select.data('dependencies')
    if (!dependencies) return {}

    let query = []
    Object.entries(dependencies).forEach(
        ([dependentSelector, name]) => {
            const value = $(dependentSelector).val()
            if (value) query.push(`${ name }=${ encodeURIComponent(value) }`)
        }
    )

    return queryString.parse(query.join('&'))
}

function fetchOptions(select) {
    const payload = gatherDependentParams(select)
    if (Object.keys(payload).length === 0) {
        select.html(buildNoDataOption(select))
        return
    }

    $.ajax({
        url: select.data('url'),
        method: 'GET',
        data: payload,
        json: true,
        success: data => applyOptions(select, data),
        error: error => console.error(error)
    })
}

function applyOptions(select, data) {
    // console.log('ajax select data resp', data)
    let html = data.options.map(
        option => buildOption(option)
    ).join("\n")

    if (html.length === 0) {
        select.html(buildNoDataOption(select))
        return
    }

    if (select.data('skip-empty') && html.length > 0) {
        select.html(html)
        return
    }

    select.html(buildEmptySelectOption(select) + "\n" + html)
}

function dependencyChanged(select) {
    select.html(buildLoadingOptions(select))
    fetchOptions(select)
}

function initialize(select) {
    const dependencies = select.data('dependencies')
    if (!dependencies) return

    Object.keys(dependencies).forEach(dependentSelector => {
        $(dependentSelector).on(
            'change', () => dependencyChanged(select)
        )
    })
}

$(document).ready(function () {
    const ajaxSelect = $(AJAX_SELECT_SELECTOR)
    initialize(ajaxSelect)
})

export default initialize
export { AJAX_SELECT_SELECTOR }
