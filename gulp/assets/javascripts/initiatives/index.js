'use strict';


angular.module('WKD.Initiatives', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.initiatives', {
      url: '/initiatives',
      template: '<ui-view>',
      redirectTo: 'wkd.initiatives.list'
    })

    .state('wkd.initiatives.list', {
      url: '/',
      action: 'list',
      templateUrl: '/templates/initiatives/list.html',
      controller: 'WKD.Initiatives.Controller',
      controllerAs: 'vm'
    })

    .state('wkd.initiatives.new', {
      url: '/new',
      redirectTo: 'wkd.initiatives.list'
    })

    .state('wkd.initiatives.view', {
      url: '/:id',
      action: 'view',
      redirectTo: 'wkd.initiatives.view.checklist',
      controller: 'WKD.Initiatives.Controller',
      controllerAs: 'vm',
      templateUrl: '/templates/initiatives/view.html'
    })

    .state('wkd.initiatives.view.edit', {
      url: '/edit',
      action: 'view',
      templateUrl: '/templates/initiatives/edit.html'
    })

    .state('wkd.initiatives.view.checklist', {
      url: '/characteristics',
      action: 'checklist',
      templateUrl: '/templates/initiatives/checklist.html',
      controller: 'WKD.Initiatives.Controller',
      controllerAs: 'vm'
    })

    ;
}])

;

require('./controller.js');
