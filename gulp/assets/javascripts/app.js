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

.config([function () {
  // Load current user
}])


.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('login', {
      url: '/login',
      templateUrl: '/templates/layout/login.html',
      controller: 'WKD.Common.LoginController',
      controllerAs: 'login'
    })

    ;
}])

.config(['$urlRouterProvider', function ($urlRouterProvider) {
  $urlRouterProvider.otherwise('/');
}])

// @todo delete this when login works
.run(['$rootScope', function ($rootScope) {
  $rootScope.$$authenticated = true;
}])

;