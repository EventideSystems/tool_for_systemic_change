'use strict';


angular.module('WKD.Activities', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.activities', {
      url: '/activities',
      template: '<ui-view class="transition-view">',
      redirectTo: 'wkd.activities.list'
    })

    .state('wkd.activities.list', {
      templateUrl: '/templates/activities/list.html',
      controller: 'WKD.Activities.ListController',
      controllerAs: 'vm',
      title: 'Activity'
    })

    ;
}])

;


require('./ListController.js');
