'use strict';


angular.module('WKD.Organisations')

.controller('WKD.Organisations.Controller', [
  'WKD.Common.SidebarService',
  function (sidebarService) {
    sidebarService.loadOrganisations();
  }
]);