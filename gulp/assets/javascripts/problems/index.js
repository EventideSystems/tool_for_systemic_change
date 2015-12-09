'use strict';


angular.module('WKD.Problems', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.problems', {
      url: '/wicked-problems',
      template: '<ui-view>',
      redirectTo: 'wkd.problems.list'
    })

    .state('wkd.problems.list', {
      url: '/',
      action: 'list',
      templateUrl: '/templates/problems/list.html',
      controller: 'WKD.Problems.Controller',
      controllerAs: 'vm',
      title: 'Wicked problems'
    })

    .state('wkd.problems.new', {
      url: '/new',
      redirectTo: 'wkd.problems.list'
    })

    .state('wkd.problems.view', {
      url: '/:id',
      action: 'view',
      controller: 'WKD.Problems.Controller',
      redirectTo: 'wkd.problems.view.edit',
      controllerAs: 'vm',
      templateUrl: '/templates/problems/view.html'
    })

    .state('wkd.problems.view.edit', {
      url: '/edit',
      action: 'view',
      templateUrl: '/templates/problems/edit.html',
      title: 'Edit wicked problem'
    })

    ;
}])

;

require('./controller.js');
