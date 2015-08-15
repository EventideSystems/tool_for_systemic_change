'use strict';


angular.module('WKD.Organisations')

.controller('WKD.Organisations.Controller', [
  'WKD.Common.SidebarService',
  'flashr',
  function (sidebarService, flashr) {
    var vm = this;
    var baseOrgs = sidebarService.baseOrganisations;

    sidebarService.loadOrganisations();

    vm.organisation = {};

    vm.submitForm = function () {
      return baseOrgs.post(vm.organisation).then(function () {
        flashr.now.success('Yay!');
      }, function () {
        flashr.now.error('Failed to create organisation');
      });
    };
  }
]);