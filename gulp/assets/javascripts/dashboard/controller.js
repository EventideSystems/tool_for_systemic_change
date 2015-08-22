'use strict';


angular.module('WKD.Dashboard')

.controller('WKD.Dashboard.Controller', [
  'WKD.Common.SidebarService',
  function (sidebarService) {
    sidebarService.loadWickedProblems();
  }
]);
