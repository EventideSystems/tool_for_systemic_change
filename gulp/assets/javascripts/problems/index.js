'use strict';


angular.module('WKD.Problems', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.wicked_problems', {
      url: '/wicked-problems',
      template: '<ui-view>',
      controller: ['WKD.Common.SidebarService', function (sidebar) {
        sidebar.loadWickedProblems();
      }]
    })

    .state('wkd.wicked_problems.new', {
      url: '/new',
      templateUrl: '/templates/problems/new.html',
      controller: 'WKD.Problems.Controller',
      controllerAs: 'vm'
    })

    ;
}])

;

require('./controller.js');
