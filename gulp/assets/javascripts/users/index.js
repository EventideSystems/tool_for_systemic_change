'use strict';


angular.module('WKD.Users', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.users', {
      url: '/users',
      template: '<ui-view class="transition-view">',
      redirectTo: 'wkd.users.list',
      controller: ['WKD.Common.SidebarService', function (sidebar) {
        if (!sidebar.currentSet.links) {
          sidebar.loadWickedProblems();
        }
      }]
    })

    .state('wkd.users.list', {
      templateUrl: '/templates/users/list.html',
      controller: 'WKD.Users.ListController',
      controllerAs: 'vm'
    })

    ;
}])

;


require('./ListController.js');
