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

    .state('wkd.users.view', {
      templateUrl: '/templates/users/edit.html',
      controller: 'WKD.Users.EditController',
      controllerAs: 'vm',
      title: 'Edit user',
      url: '/:id'
    })

    ;
}])

;


require('./list-controller.js');
require('./edit-controller.js');
