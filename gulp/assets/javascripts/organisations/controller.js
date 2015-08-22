'use strict';


angular.module('WKD.Organisations')

.controller('WKD.Organisations.Controller', [
  'WKD.Common.SidebarService',
  'WKD.Common.ResourceFactory',
  'flashr',
  function (sidebarService, resourceFactory, flashr) {
    var vm = this;
    var baseOrgs = resourceFactory.cache.Organisations;

    sidebarService.loadOrganisations();

    vm.organisation = {};

    vm.submitForm = function () {
      return baseOrgs.post(resourceFactory.pack(vm.factory)).then(function () {
        flashr.now.success('Yay!');
      }, function (resp) {
        vm.errors = resp.errors;
        flashr.now.error('Failed to create organisation');
      });
    };
  }
]);
