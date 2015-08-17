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

// @todo extract to own file
.controller('WKD.MainController', [
  '$state',
  '$rootScope',
  'WKD.Common.CurrentUser',
  function ($state, $rootScope, CurrentUser) {
    var app = this;

    $rootScope.$on('$stateChangeSuccess', setContextClass);

    app.currentUser = CurrentUser.get();

    setContextClass();

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
