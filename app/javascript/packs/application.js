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

require("admin-lte");
require("select2");
require("smartwizard");
require('d3');
require('d3-bboxCollide');
require('moment');
require("@nathanvda/cocoon")

import 'select2';

import * as d3Base from 'd3'
import { bboxCollide } from 'd3-bboxCollide';
import { forceCluster } from 'd3-force-cluster'
const d3 = Object.assign(d3Base, { bboxCollide, forceCluster })
window.d3 = d3;

import moment from 'moment'
moment.locale('en')
window.moment = moment;

import 'daterangepicker';

require("bootstrap");

require("../components/datepickers");
require("../components/transition_card");
require("../components/transition_card_wizard");
require("../components/initiative_checklist");
require("../components/initiatives");
require("../components/spinner");
require("../components/subsystem_tags");
require("../components/toasts");
require("../components/modals");
require("../components/ecosystem_maps");


$(document).on('turbolinks:load', function() {
  $(function () {
    jQuery('[data-toggle="tooltip"]').tooltip({ boundary: 'window' })
  });
});

import "controllers"

//trix editor
import 'trix/dist/trix.css'
import 'trix/dist/trix.js'
