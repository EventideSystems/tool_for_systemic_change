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

.config(['RestangularProvider', function (RestangularProvider) {
  // add a response interceptor to unwrap { data: [.. data i want ..]}
  RestangularProvider.addResponseInterceptor(function (resp, operation) {
    var unpacked = resp.data;

    if (operation === 'get') {
      unpacked = _.extend(unpacked, unpacked.attributes);
      delete unpacked.attributes;
    }

    return unpacked;
  });

  // Repacks resource to match server expectation
  RestangularProvider.setRequestInterceptor(function (res, operation) {
    var packed = { data: {} };

    if (operation === 'put') {
      packed.data.attributes = res;
      packed.data.id = res.id;
      packed.data.relationships = res.relationships;
      packed.data.type = res.type;

      delete packed.data.attributes.relationships;
      delete packed.data.attributes.id;
      delete packed.data.attributes.type;

      return packed;
    }

    if (operation === 'post') {
      packed.data.attributes = res;
      return packed;
    }

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
