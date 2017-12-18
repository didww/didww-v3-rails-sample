# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

form = '.js-trunks-form '
trunk_group_select = form + '.js-trunk-group-select select'
trunk_group_fields = '#trunk_priority, #trunk_weight, #trunk_ringing_timeout'

toggle_group_fields = ->
  $(trunk_group_fields).prop('disabled', !$(trunk_group_select).val())

$.onmount form, ->
  $(trunk_group_select).change ->
    toggle_group_fields()
  .change()

  # Expand all panes containing fields with error
  $('.js-collapsible-panel').each ->
    if $(@).find('.has-error').length > 0
      $(@).find('div.panel-collapse').collapse('show')
