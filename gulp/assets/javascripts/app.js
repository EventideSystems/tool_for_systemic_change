'use strict';

// Globals
window.angular = require('angular');
window._ = require('lodash');

// Vendor
require('angular-ui-router');
require('angular-ui-bootstrap');

// App Features
require('./common');
require('./dashboard');
require('./organisations');


// Application module
angular.module('WKD', [
  // Vendor
  'ui.router',
  'ui.bootstrap',

  // Features
  'WKD.Common',
  'WKD.Dashboard',
  'WKD.Organisations'
])

.config(['$urlRouterProvider', function ($urlRouterProvider) {
  $urlRouterProvider.otherwise('/');
}])

;