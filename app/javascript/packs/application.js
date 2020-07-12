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

require("@rails/ujs").start();
require("turbolinks").start();
// require("@rails/activestorage").start();
// require("channels");

var jQuery = require("jquery");

// import jQuery from "jquery";
global.$ = global.jQuery = jQuery;
window.$ = window.jQuery = jQuery;

require("bootstrap");
require("admin-lte");
require("select2");
require("smartwizard");
require("cocoon");
require('d3');
require('moment');

import 'cocoon';
import 'select2';

import * as d3 from 'd3';
window.d3 = d3;

import moment from 'moment'
moment.locale('en')
window.moment = moment;

// import 'bootstrap-datepicker'
import 'bootstrap-daterangepicker'

require("../components/transition_card");
require("../components/transition_card_wizard");
require("../components/initiative_checklist");
require("../components/subsystem_tags");
require("../components/toasts");

