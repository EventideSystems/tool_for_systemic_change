'use strict';

angular.module('WKD.Reports', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.reports', {
      url: '/reports',
      template: '<ui-view>',
      redirectTo: 'wkd.reports.index'
    })

    .state('wkd.reports.index', {
      templateUrl: '/templates/reports/index.html',
      url: '',
      title: 'Reports'
    })

    .state('wkd.reports.initiatives', {
      title: 'Initiatives report',
      url: '/initiatives',
      templateUrl: '/templates/reports/initiatives.html',
      controller: 'WKD.Reports.InitiativesController',
      controllerAs: 'vm'
    })

    .state('wkd.reports.stakeholders', {
      title: 'Stakeholders report',
      url: '/stakeholders',
      templateUrl: '/templates/reports/stakeholders.html',
      controller: 'WKD.Reports.StakeholdersController',
      controllerAs: 'vm'
    })

    ;
}])

;

require('./initiatives-controller.js');
require('./stakeholders-controller.js');

