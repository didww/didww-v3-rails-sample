import onMount from 'onmount'

const container = '.js-balance '
const reloadButton = `${container}.js-balance-reload `
const detailsDiv = `${container} > div`
const balanceDetail = field => $(`${container}[data-balance-detail="${field}"] `)

onMount(container, () =>
  $(reloadButton).click(() => {
    $(reloadButton).attr('disabled', true)
    $(`${reloadButton}i.fa`).addClass('fa-spin')
    return $.get({
      url: '/balance',
      dataType: 'json'
    }).done((json) => {
      $(reloadButton).attr('disabled', false)
      $(`${reloadButton}i.fa`).removeClass('fa-spin')
      $(detailsDiv).hide().fadeIn()
      return $.each(json, (key, val) => balanceDetail(key).text(val))
    })
  }))
