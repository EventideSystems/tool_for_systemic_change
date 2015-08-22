'use strict';


angular.module('WKD.Initiatives', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.initiatives', {
      url: '/initiatives',
      template: '<ui-view>',
      controller: ['WKD.Common.SidebarService', function (sidebar) {
        sidebar.loadInitiatives();
      }]
    })

    .state('wkd.initiatives.new', {
      url: '/new',
      template: '/templates/initiatives/new.html',
      controller: 'WKD.Initiatives.Controller'
    })

    ;
}])

;

require('./controller.js');
