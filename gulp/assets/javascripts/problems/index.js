'use strict';


angular.module('WKD.Problems', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.wicked_problems', {
      url: '/wicked-problems',
      template: '<ui-view class="transition-view">'
    })

    .state('wkd.wicked_problems.new', {
      url: '/new',
      action: 'new',
      templateUrl: '/templates/problems/new.html',
      controller: 'WKD.Problems.NewController',
      controllerAs: 'vm'
    })

    .state('wkd.wicked_problems.view', {
      url: '/:id',
      action: 'view',
      redirectTo: 'wkd.wicked_problems.view.edit',
      templateUrl: '/templates/problems/view.html',
      resolve: {
        currentProblem: ['Restangular', '$stateParams', function (Restangular, $stateParams) {
          return Restangular.one('wicked_problems', $stateParams.id).get();
        }]
      },
      controller: ['$scope', 'currentProblem', function ($scope, problem) {
        $scope.problem = problem;
      }]
    })

    .state('wkd.wicked_problems.view.edit', {
      url: '/edit',
      controller: 'WKD.Problems.EditController',
      controllerAs: 'vm',
      templateUrl: '/templates/problems/edit.html'
    })

    .state('wkd.wicked_problems.view.initiatives', {
      url: '/initiatives',
      templateUrl: '/templates/problems/initiatives.html',
      controller: 'WKD.Problems.InitiativeController',
      controllerAs: 'vm'
    })

    ;
}])

;

require('./new-controller.js');
require('./edit-controller.js');
require('./initiative-controller.js');

