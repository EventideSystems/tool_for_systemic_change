'use strict';


angular.module('WKD.Organisations', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.organisations', {
      url: '/organisations',
      template: '<ui-view>',
      redirectTo: 'wkd.organisations.list',
      title: 'Organisations'
    })

    .state('wkd.organisations.list', {
      url: '/',
      action: 'list',
      templateUrl: '/templates/organisations/list.html',
      controller: 'WKD.Organisations.Controller',
      controllerAs: 'vm',
      title: 'Organisations'
    })

    .state('wkd.organisations.new', {
      url: '/new',
      redirectTo: 'wkd.organisations.list'
    })

    .state('wkd.organisations.view', {
      url: '/:id',
      action: 'view',
      controller: 'WKD.Organisations.Controller',
      redirectTo: 'wkd.organisations.view.edit',
      controllerAs: 'vm',
      templateUrl: '/templates/organisations/view.html',
      title: 'New organisation'
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
