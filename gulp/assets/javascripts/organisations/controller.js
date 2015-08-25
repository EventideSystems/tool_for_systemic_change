'use strict';


angular.module('WKD.Organisations')

.controller('WKD.Organisations.Controller', [
  'WKD.Common.SidebarService',
  '$state',
  'Restangular',
  'flashr',
  '$controller',
  function (sidebarService, $state, Restangular, flashr, $controller) {
    var vm = this;
    var baseRef = Restangular.all('communities');

    vm._new = function () {
      vm.community = {};
      vm.submitForm = create;
    };

    vm._view = function (params) {
      vm.submitForm = update;
      vm.deleteResource = destroy;
      Restangular.one('organisations', params.id).get().then(function (resp) {
        vm.organisation = resp;
      });
    };

    $controller('WKD.Common.RESTController', { $scope: vm });

    function create() {
      return baseRef.post(vm.organisation).then(function (organisation) {
        sidebarService.addLink(organisation);
        $state.go('^.view', { id: organisation.id });
        flashr.later.success('Organisation successfully created!');
      }, function (resp) {
        vm.errors = resp.errors;
        flashr.now.error('Failed to create organisation');
      });
    }

    function update() {
      return vm.organisation.put().then(function () {
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
