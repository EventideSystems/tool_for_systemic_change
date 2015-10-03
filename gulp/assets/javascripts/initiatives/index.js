'use strict';


angular.module('WKD.Initiatives', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.initiatives', {
      url: '/initiatives',
      template: '<ui-view>'
    })

   .state('wkd.initiatives.new', {
      url: '/new',
      action: 'new',
      templateUrl: '/templates/initiatives/new.html',
      controller: 'WKD.Initiatives.Controller',
      controllerAs: 'vm'
    })

    .state('wkd.initiatives.view', {
      url: '/:id',
      action: 'view',
      redirectTo: 'wkd.initiatives.view.edit',
      templateUrl: '/templates/initiatives/view.html'
    })

    .state('wkd.initiatives.view.edit', {
      url: '/edit',
      action: 'view',
      controller: 'WKD.Initiatives.Controller',
      controllerAs: 'vm',
      templateUrl: '/templates/initiatives/edit.html'
    })

    .state('wkd.initiatives.view.checklist', {
      url: '/checklist',
      action: 'checklist',
      controller: 'WKD.Initiatives.Controller',
      controllerAs: 'vm',
      templateUrl: '/templates/initiatives/checklist.html'
    })

    ;
}])

;

require('./controller.js');
