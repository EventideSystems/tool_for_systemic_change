'use strict';


angular.module('WKD.Problems')

.controller('WKD.Problems.Controller', [
  '$state',
  'Restangular',
  'flashr',
  '$controller',
  '$scope',
  function ($state, Restangular, flashr, $controller, $scope) {
    var vm = this;
    var baseRef = Restangular.all('wicked_problems');

    vm._list = function () {
      vm.problem = {};
      vm.submitForm = create;
      vm.insideModal = !$state.current.name.match('problems');
      baseRef.getList().then(function (resp) {
        vm.problems = resp;
      });
    };

    vm._view = function (params) {
      vm.submitForm = update;
      vm.deleteResource = destroy;
      Restangular.one('wicked_problems', params.id).get().then(function (res) {
        vm.problem = res;
      });
    };

    $controller('WKD.Common.RESTController', { $scope: vm });

    function create() {
      return baseRef.post(vm.problem).then(function (problem) {
        if (vm.insideModal) {
          flashr.now.success('Wicked problem successfully created!');
          $scope.$close(problem);
        } else {
          $state.go('^.view', { id: problem.id });
          flashr.later.success('Wicked problem successfully created!');
        }
      }, function (resp) {
        vm.errors = resp.errors;
        flashr.now.error('Failed to create wicked problem');
      });
    }

    function update() {
      return vm.problem.put().then(function () {
        flashr.now.success('Wicked problem updated!');
      });
    }

    function destroy() {
      if (!window.confirm('Are you sure you want to delete this?')) return;

      vm.problem.remove().then(function () {
        flashr.later.success('Wicked problem deleted');
        $state.go('wkd.dashboard');
      });
    }
  }
]);
