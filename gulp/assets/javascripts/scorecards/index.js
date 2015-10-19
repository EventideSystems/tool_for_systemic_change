'use strict';


angular.module('WKD.Scorecards', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.scorecards', {
      url: '/scorecards',
      template: '<ui-view class="transition-view">',
      redirectTo: 'wkd.scorecards.list'
    })

    .state('wkd.scorecards.list', {
      url: '/',
      action: 'list',
      templateUrl: '/templates/scorecards/list.html',
      controller: 'WKD.Scorecards.ListController',
      controllerAs: 'vm'
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
      redirectTo: 'wkd.scorecards.view.scorecard',
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

    .state('wkd.scorecards.view.scorecard', {
      url: '/view',
      controller: 'WKD.Scorecards.ScorecardController',
      controllerAs: 'vm',
      templateUrl: '/templates/scorecards/scorecard.html'
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
require('./list-controller.js');
require('./initiative-controller.js');
require('./scorecard-controller.js');

