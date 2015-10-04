'use strict';


angular.module('WKD.Scorecards', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.scorecards', {
      url: '/scorecards',
      template: '<ui-view class="transition-view">',
      redirectTo: 'wkd.scorecards.new'
    })

    .state('wkd.scorecards.new', {
      url: '/new',
      action: 'new',
      templateUrl: '/templates/scorecards/new.html',
      controller: 'WKD.Scorecards.NewController',
      controllerAs: 'vm'
    })

    .state('wkd.scorecards.view', {
      url: '/:id',
      action: 'view',
      redirectTo: 'wkd.scorecards.view.edit',
      templateUrl: '/templates/scorecards/view.html',
      resolve: {
        currentCard: ['Restangular', '$stateParams', function (Restangular, $stateParams) {
          return Restangular.one('scorecards', $stateParams.id).get();
        }]
      },
      controller: ['$scope', 'currentCard', function ($scope, card) {
        $scope.scorecard = card;
      }]
    })

    .state('wkd.scorecards.view.edit', {
      url: '/edit',
      controller: 'WKD.Scorecards.EditController',
      controllerAs: 'vm',
      templateUrl: '/templates/scorecards/edit.html'
    })

    .state('wkd.scorecards.view.initiatives', {
      url: '/initiatives',
      templateUrl: '/templates/scorecards/initiatives.html',
      controller: 'WKD.Scorecards.InitiativeController',
      controllerAs: 'vm'
    })

    ;
}])

;

require('./new-controller.js');
require('./edit-controller.js');
require('./initiative-controller.js');

