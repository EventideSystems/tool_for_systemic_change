'use strict';

// Globals
window.angular = require('angular');
window._ = require('lodash');
window.toastr = require('toastr');

// Vendor
require('angular-ui-router');
require('angular-ui-bootstrap');
require('restangular');
require('angular-wizard');
require('angular-messages');
require('angular-animate');
require('angular-aria');

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
  'ngMessages',
  'flashr',
  'mgo-angular-wizard',
  'ngAnimate',
  'ngAria',

  // Features
  'WKD.Common',
  'WKD.Dashboard',
  'WKD.Organisations',
  'WKD.Problems',
  'WKD.Initiatives',
  'WKD.Communities'
])


.config(['$stateProvider', 'WKD.Common.CurrentUserProvider', function ($stateProvider, CurrentUserProvider) {
  $stateProvider
    .state('wkd', {
      url: '',
      abstract: true,
      controller: 'WKD.MainController',
      controllerAs: 'WKD',
      template: '<ui-view>',
      resolve: { currentUser: CurrentUserProvider.resolveCurrentUser }
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

.config(['RestangularProvider', 'WKD.Common.DefaultPackerProvider', function (RestangularProvider, defaultPacker) {
  // add a response interceptor to unwrap { data: [.. data i want ..]}
  RestangularProvider.addResponseInterceptor(function (resp, operation) {
    var unpacked = resp.data;

    if (operation === 'get') unpacked = defaultPacker.unpackResource(unpacked);
    if (resp.included) unpacked.included = resp.included;
    return unpacked;
  });

  // Repacks resource to match server expectation
  RestangularProvider.addRequestInterceptor(function (res, op) {
    if (op === 'post' || op === 'put') return defaultPacker.packResource(res);
    return res;
  });
}])

// Monkey patch redirectTo into ui router.
.run(['$rootScope', '$state', function ($rootScope, $state) {
  $rootScope.$on('$stateChangeStart', function (evt, to, params) {
    if (to.redirectTo) {
      evt.preventDefault();
      $state.go(to.redirectTo, params);
    }
  });
}])

// @todo extract to own file
.controller('WKD.MainController', [
  '$state',
  '$rootScope',
  'WKD.Common.CurrentUser',
  function ($state, $rootScope, CurrentUser) {
    var app = this;

    $rootScope.$on('$stateChangeSuccess', setContextClass);

    app.currentUser = CurrentUser.get();

    setContextClass(null, $state.current);

    function setContextClass(e, cur) {
      try {
        $rootScope.contextClass = cur.name.match(/wkd\.(\w+)/)[1] + '-page';
        $rootScope.contextClass = $rootScope.contextClass.replace('_', '-');
      } catch (e) {
        $rootScope.contextClass = 'dashboard-page';
      }
    }
  }
])

;
