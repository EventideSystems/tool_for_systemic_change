'use strict';


angular.module('WKD.Organisations', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.organisations', {
      url: '/organisations',
      template: '<ui-view>'
    })

    .state('wkd.organisations.new', {
      url: '/new',
      action: 'new',
      templateUrl: '/templates/organisations/new.html',
      controller: 'WKD.Organisations.Controller',
      controllerAs: 'vm'
    })

    .state('wkd.organisations.view', {
      url: '/:id',
      action: 'view',
      controller: 'WKD.Organisations.Controller',
      redirectTo: 'wkd.organisations.view.edit',
      controllerAs: 'vm',
      templateUrl: '/templates/organisations/view.html'
    })

    .state('wkd.organisations.view.edit', {
      url: '/edit',
      action: 'view',
      templateUrl: '/templates/organisations/edit.html'
    })

    ;
}])

;

require('./controller.js');
