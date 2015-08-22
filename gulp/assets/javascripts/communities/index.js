'use strict';


angular.module('WKD.Communities', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.communities', {
      url: '/communities',
      template: '<ui-view>',
      controller: ['WKD.Common.SidebarService', function (sidebar) {
        sidebar.loadCommunities();
      }]
    })

    .state('wkd.communities.new', {
      url: '/new',
      templateUrl: '/templates/communities/new.html',
      controller: 'WKD.Communities.Controller',
      controllerAs: 'vm'
    })

    ;
}])

;

require('./controller.js');
