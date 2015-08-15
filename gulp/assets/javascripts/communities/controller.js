'use strict';


angular.module('WKD.Communities')

.controller('WKD.Communities.Controller', [
  'WKD.Common.SidebarService',
  function (sidebarService) {
    sidebarService.loadCommunities();
  }
]);