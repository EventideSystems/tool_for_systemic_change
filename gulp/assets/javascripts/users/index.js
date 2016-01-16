'use strict';


angular.module('WKD.Users', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.users', {
      url: '/users',
      template: '<ui-view class="transition-view">',
      redirectTo: 'wkd.users.list'
    })

    .state('wkd.users.list', {
      templateUrl: '/templates/users/list.html',
      controller: 'WKD.Users.ListController',
      controllerAs: 'vm',
      title: 'Users'
    })

    ;
}])

;


require('./ListController.js');
