'use strict';

// Globals
window.angular = require('angular');
window._ = require('lodash');
window.toastr = require('toastr');

// Vendor
require('angular-ui-router');
require('angular-ui-bootstrap');
require('restangular');
require('../../../node_modules/angular.flashr/angular-flashr.js');

// App Features
require('./common');
require('./dashboard');
require('./organisations');
require('./problems');
require('./initiatives');
require('./communities');


// Application module
angular.module('WKD', [
  // Vendor
  'ui.router',
  'ui.bootstrap',
  'restangular',
  'flashr',

  // Features
  'WKD.Common',
  'WKD.Dashboard',
  'WKD.Organisations',
  'WKD.Problems',
  'WKD.Initiatives',
  'WKD.Communities'
])


.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd', {
      url: '',
      abstract: true,
      template: '<ui-view>',
      // resolve: resolve current user here
    })

    ;
}])

.config(['$urlRouterProvider', function ($urlRouterProvider) {
  $urlRouterProvider.otherwise('/');

  window.toastr.options = {
    debug: false,
    positionClass: 'toast-bottom-right',
    fadeIn: 200,
    fadeOut: 200
  };

}])

;