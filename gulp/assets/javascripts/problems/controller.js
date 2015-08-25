'use strict';


angular.module('WKD.Problems')

.controller('WKD.Problems.Controller', [
  'WKD.Common.SidebarService',
  '$modal',
  'Restangular',
  function (sidebarService, $modal, Restangular) {
    var vm = this;

    vm.newProblem = {};

    Restangular.all('communities').getList().then(function (resp) {
      vm.communities = resp;
      vm.newProblem.community = _.first(vm.communities);
    });

    vm.openModal = function (resource) {
      $modal.open({
        templateUrl: '/templates/problems/' + resource + '-modal.html',
        controller: 'WKD.Communities.Controller',
        controllerAs: 'vm',
        size: 'lg'
      }).result.then(function (resp) {
        vm.newProblem[resource] = resp;
        vm.communities.push(resp);
      });
    };
  }
]);
