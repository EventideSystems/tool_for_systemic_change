'use strict';


angular.module('WKD.Problems')

.controller('WKD.Problems.Controller', [
  'WKD.Common.SidebarService',
  function (sidebarService) {
    sidebarService.loadWickedProblems();
  }
]);