'use strict';


angular.module('WKD.Users')

.controller('WKD.Users.EditController', [
  'Restangular',
  'flashr',
  'WKD.Common.CurrentUser',
  '$state',
  '$stateParams',
  function (Restangular, flashr, currentUser, $state, $stateParams) {
    var vm = this;

    if (!currentUser.hasRole('admin')) $state.go('wkd.dashboard');

    Restangular.one('users', $stateParams.id).get().then(function (user) {
      vm.user = user;
    });

    vm.save = function () {
      vm.user.put().then(function () {
        flashr.now.success('User updated');
      }, function (resp) {
        flashr.now.error(resp.data.errors);
      });
    };

    vm.deleteUser = function () {
      if (window.confirm('Are you sure?')) {
        vm.user.remove().then(function () {
          $state.go('wkd.users');
          flashr.later.success('User deleted');
        }, function (resp) {
          flashr.now.error(resp.data.errors);
        });
      }
    };
  }
])



;
