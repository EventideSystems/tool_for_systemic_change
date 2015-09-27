'use strict';


angular.module('WKD.Users')

.controller('WKD.Users.ListController', [
  'Restangular',
  '$http',
  'flashr',
  function (Restangular, $http, flashr) {
    var vm = this;
    var baseRef = Restangular.all('users');

    baseRef.getList().then(function (users) {
      vm.users = _.where(users, { attributes: { status: 'active' } });
      vm.pending = _.where(users, { attributes: { status: 'invitation-pending' } });
    });

    vm.inviteUser = function () {
      var data = angular.copy(vm.newUser);
      data.role = data.isAdmin ? 'admin' : 'user';
      delete data.isAdmin;
      // delete data.name; // temporary delete until api supports

      $http.post('/users/invitation', { user: data }).then(function (resp) {
        vm.pending.push(resp.data.data);

        flashr.now.success(
          'An invitation email has been sent to ' + data.email
        );

        vm.newUserForm.name.$touched = false;
        vm.newUserForm.email.$touched = false;
        vm.newUser = null;
      });
    };

  }
])



;
