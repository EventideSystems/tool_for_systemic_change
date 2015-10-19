'use strict';


angular.module('WKD.Communities')

.controller('WKD.Communities.Controller', [
  '$state',
  'Restangular',
  'flashr',
  '$controller',
  '$scope',
  function ($state, Restangular, flashr, $controller, $scope) {
    var vm = this;
    var baseRef = Restangular.all('communities');

    vm._list = function () {
      vm.community = {};
      vm.submitForm = create;
      baseRef.getList().then(function (resp) {
        vm.communities = resp;
      });
    };

    vm._new = function () {
      vm.insideModal = true;
      vm.community = {};
      vm.submitForm = create;
      vm.action = 'list';
    };

    vm._view = function (params) {
      vm.submitForm = update;
      vm.deleteResource = destroy;
      Restangular.one('communities', params.id).get().then(function (resp) {
        vm.community = resp;
      });
    };

    $controller('WKD.Common.RESTController', { $scope: vm });

    function create() {
      return baseRef.post(vm.community).then(function (community) {
        if (vm.insideModal) {
          flashr.now.success('Community successfully created!');
          $scope.$close(community);
        } else {
          $state.go('^.view', { id: community.id });
          flashr.later.success('Community successfully created!');
        }
      }, function (resp) {
        vm.errors = resp.errors;
        console.log(vm.errors);
        flashr.now.error('Failed to create community');
      });
    }

    function update() {
      return vm.community.put().then(function () {
        flashr.now.success('Community updated!');
      });
    }

    function destroy() {
      if (!window.confirm('Are you sure you want to delete this?')) return;

      vm.community.remove().then(function () {
        flashr.later.success('Community deleted');
        $state.go('wkd.communities');
      });
    }
  }
]);
