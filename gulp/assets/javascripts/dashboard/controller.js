'use strict';


angular.module('WKD.Dashboard')

.controller('WKD.Dashboard.Controller', [
  'WKD.Common.SidebarService',
  '$rootScope',
  function (sidebarService, $rootScope) {
    sidebarService.loadProblems();
  }
]);