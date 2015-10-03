'use strict';


angular.module('WKD.Communities', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.communities', {
      url: '/communities',
      template: '<ui-view>'
    })

    .state('wkd.communities.new', {
      url: '/new',
      action: 'new',
      templateUrl: '/templates/communities/new.html',
      controller: 'WKD.Communities.Controller',
      controllerAs: 'vm'
    })

    .state('wkd.communities.view', {
      url: '/:id',
      action: 'view',
      controller: 'WKD.Communities.Controller',
      redirectTo: 'wkd.communities.view.edit',
      controllerAs: 'vm',
      templateUrl: '/templates/communities/view.html'
    })

    .state('wkd.communities.view.edit', {
      url: '/edit',
      action: 'view',
      templateUrl: '/templates/communities/edit.html'
    })

    ;
}])

;

require('./controller.js');
