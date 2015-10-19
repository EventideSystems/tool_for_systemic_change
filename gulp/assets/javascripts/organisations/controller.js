'use strict';


angular.module('WKD.Organisations')

.controller('WKD.Organisations.Controller', [
  '$state',
  'Restangular',
  'flashr',
  '$controller',
  function ($state, Restangular, flashr, $controller) {
    var vm = this;
    var baseRef = Restangular.all('organisations');

    vm._list = function () {
      vm.organisation = {};
      vm.submitForm = create;
      baseRef.getList().then(function (resp) {
        vm.organisations = resp;
      });
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
        vm.organisations.push(organisation);
        vm.organisation = {};
        vm.orgForm.$setUntouched();
        flashr.now.success('Organisation successfully created!');
      }, function (resp) {
        vm.errors = resp.errors;
        flashr.now.error('Failed to create organisation');
      });
    }

    function update() {
      return vm.organisation.put().then(function () {
        flashr.now.success('Organisation updated!');
      });
    }

    function destroy() {
      if (!window.confirm('Are you sure you want to delete this?')) return;

      vm.organisation.remove().then(function () {
        flashr.later.success('Organisation deleted');
        $state.go('wkd.organisations');
      });
    }
  }
]);
