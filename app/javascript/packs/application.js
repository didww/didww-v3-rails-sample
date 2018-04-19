/* eslint no-console:0 */
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

require('../styles/application.scss')
import 'jquery'
import Rails from 'rails-ujs'
import Turbolinks from 'turbolinks'
import 'bootstrap/dist/js/bootstrap'
import onMount from 'onmount'
import 'metismenu/dist/metisMenu'
import 'startbootstrap-sb-admin-2/dist/js/sb-admin-2'
import 'bootstrap-datepicker/dist/js/bootstrap-datepicker'

import initDraggableMultiselect from 'includes/draggable_multiselect'
import 'includes/clickable_row'
import 'includes/balance'
import 'includes/coverage_cart'
import 'includes/coverage_filter'
import 'includes/dids'
import 'includes/orders'
import 'includes/trunks'

console.log('Hello World from Webpacker')

Rails.start()
Turbolinks.start()

onMount('.js-metismenu', function(){
    $(this).metisMenu()
})

onMount('.js-two-way-select', function(){
    initDraggableMultiselect($(this))
})

$(document).on('ready turbolinks:load turbolinks:render ajaxComplete', function(){
    onMount()
})
