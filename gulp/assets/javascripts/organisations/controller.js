'use strict';


angular.module('WKD.Organisations')

.controller('WKD.Organisations.Controller', [
  'WKD.Common.SidebarService',
  'WKD.Common.ResourceFactory',
  'flashr',
  '$state',
  'Restangular',
  function (sidebarService, resourceFactory, flashr, $state, Restangular) {
    var vm = this;
    var baseOrgs = resourceFactory.cache.Organisations;

    vm.action = $state.current.action;

    if (vm.action === 'view') {
      vm.submitForm = update;
      vm.deleteOrg = destroy;
      Restangular.one('organisations', $state.params.id).get()
        .then(function (org) {
          vm.organisation = org;
        });
    } else {
      vm.organisation = {};
      vm.submitForm = create;
    }

    function create() {
      return baseOrgs.post(vm.organisation).then(function (organisation) {
        sidebarService.addLink(organisation);
        $state.go('^.view', { id: organisation.id });
        flashr.later.success('Organisation successfully created!');
      }, function (resp) {
        vm.errors = resp.errors;
        flashr.now.error('Failed to create organisation');
      });
    }

    function update() {
      return vm.organisation.put().then(function (resp) {
        sidebarService.updateLink(vm.organisation);
        flashr.now.success('Organisation updated!');
      });
    }

    function destroy() {
      if (!window.confirm('Are you sure you want to delete this?')) return;

      vm.organisation.remove().then(function () {
        flashr.later.success('Organisation deleted');
        $state.go('wkd.dashboard');
      });
    }
  }
]);
