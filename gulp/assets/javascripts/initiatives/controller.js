'use strict';


angular.module('WKD.Initiatives')

.controller('WKD.Initiatives.Controller', [
  'WKD.Common.SidebarService',
  function (sidebarService) {
    sidebarService.loadInitiatives();
  }
]);