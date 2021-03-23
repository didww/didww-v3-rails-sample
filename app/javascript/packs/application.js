/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import '../styles/application' // css
import Rails from "@rails/ujs"
import Turbolinks from 'turbolinks'
import 'jquery'
import 'gritter/js/jquery.gritter'
import 'bootstrap'
import 'onmount'
import 'metismenu'
import '../../../vendor/assets/sbadmin2/sbadmin2'
import 'bootstrap-datepicker'
import '../includes/ajax_select'
import '../includes/batch_actions'
import '../ui/available_dids'
import '../ui/balance'
import '../ui/capacity_order_calculation'
import '../ui/coverage_cart'
import '../ui/coverage_filter'
import '../ui/did_reservations'
import '../ui/dids'
import '../ui/orders'
import '../ui/trunks'
import '../includes/onmount_attach'
import '../channels/notification_channel'
import '../ui/proofs'
import '../ui/permanent_supporting_documents'
import '../ui/requirement_validation'
import '../ui/encryption'

Rails.start()
Turbolinks.start()
