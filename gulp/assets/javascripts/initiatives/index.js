'use strict';


angular.module('WKD.Initiatives', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.initiatives', {
      url: '/initiatives',
      template: '<ui-view>',
      controller: ['WKD.Common.SidebarService', function (sidebar) {
        sidebar.loadInitiatives();
      }]
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
      controller: 'WKD.Initiatives.Controller',
      redirectTo: 'wkd.initiatives.view.edit',
      controllerAs: 'vm',
      templateUrl: '/templates/initiatives/view.html'
    })

    .state('wkd.initiatives.view.edit', {
      url: '/edit',
      action: 'view',
      templateUrl: '/templates/initiatives/edit.html'
    })

    ;
}])

;

require('./controller.js');
