'use strict';


angular.module('WKD.Organisations')

.controller('WKD.Organisations.Controller', [
  '$state',
  'Restangular',
  'flashr',
  '$controller',
  '$scope',
  function ($state, Restangular, flashr, $controller, $scope) {
    var vm = this;
    var baseRef = Restangular.all('organisations');

    vm._list = function () {
      vm.organisation = {};
      vm.submitForm = create;
      baseRef.getList().then(function (resp) {
        vm.organisations = resp;
      });
      vm.action = 'list';
      vm.insideModel = !$state.current.name.match('organisations');
    };

    vm._new = vm._list;

    vm._view = function (params) {
      vm.submitForm = update;
      vm.deleteResource = destroy;
      Restangular.one('organisations', params.id).get().then(function (resp) {
        vm.organisation = resp;
      });
    };

    vm.backToInitiative = function () {
      $scope.$emit('organisation:hideForm');
    };

    $controller('WKD.Common.RESTController', { $scope: vm });

    $scope.$on('organisation:error', function (e, resp) {
      vm.errors = resp.data;
      flashr.now.error('Failed to create organisation');
    });

    function create() {
      if (vm.insideModel) {
        return $scope.$emit('organisation:create', {
          ref: baseRef,
          organisation: vm.organisation
        });
      }

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
