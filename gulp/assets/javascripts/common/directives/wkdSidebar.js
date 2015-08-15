'use strict';

angular.module('WKD.Common')

.directive('wkdSidebar', [
  '$state',
  'WKD.Common.SidebarService',
  function ($state, sidebarService) {
    return {
      restrict: 'E',
      link: function (scope) {
        scope.sidebar = sidebarService.currentSet;
        scope.contextMenu = sidebarService.CONTEXT_MENU;

        scope.load = function (resource) {
          return sidebarService['load' + resource.replace('_', '')]();
        };

        scope.gotoNewForm = function () {
          $state.go(scope.sidebar.options.newState);
        };
      },
      templateUrl: '/templates/directives/wkd-sidebar.html'
    };
  }
]);