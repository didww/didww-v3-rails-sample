container      = '.js-balance '
reload_button  = container + '.js-balance-reload '
details_div    = container + ' > div'
balance_detail = (field) ->
  $(container + '[data-balance-detail="' + field + '"] ')

$.onmount container, ->
  $(reload_button).click ->
    $(reload_button).attr('disabled', true)
    $(reload_button + 'i.fa').addClass('fa-spin')
    $.get
      url: '/balance',
      dataType: 'json'
    .done (json) ->
      $(reload_button).attr('disabled', false)
      $(reload_button + 'i.fa').removeClass('fa-spin')
      $(details_div).hide().fadeIn()
      $.each json, (key, val) ->
        balance_detail(key).text(val)
