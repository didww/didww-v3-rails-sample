# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

form = '.js-dids-form '
tr_select = form + '.js-trunk-select select'
tg_select = form + '.js-trunk-group-select select'


# DID can either be assigned to Trunk, or TrunkGroup.
$.onmount form, ->
  $(tr_select).change ->
    $(tg_select).val("")

  $(tg_select).change ->
    $(tr_select).val("")
