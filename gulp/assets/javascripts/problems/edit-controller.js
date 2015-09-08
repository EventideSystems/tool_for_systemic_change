'use strict';


angular.module('WKD.Problems')

.controller('WKD.Problems.EditController', [
  'Restangular',
  'flashr',
  '$stateParams',
  'WKD.Common.SidebarService',
  '$state',
  'currentProblem', //injected by resolve
  function (Restangular, flashr, $stateParams, sidebarService, $state, currentProblem) {
    var vm = this;

    Restangular.all('communities').getList().then(function (resp) {
      vm.communities = resp;
    });

    vm.problem = currentProblem;

    vm.update = function () {
      return vm.problem.put().then(function () {
        sidebarService.updateLink(vm.problem);
        flashr.now.success('Wicked problem updated!');
      });
    };

    vm.destroy = function () {
      if (!window.confirm('Are you sure you want to delete this?')) return;

      vm.problem.remove().then(function () {
        sidebarService.removeLink(vm.problem);
        flashr.later.success('Wicked problem deleted');
        $state.go('wkd.dashboard');
      });
    };

    /////////////////////////////////////////////////////////////////////////


  }
]);
