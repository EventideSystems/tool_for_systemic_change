'use strict';


angular.module('WKD.Users')

.controller('WKD.Users.ListController', [
  'Restangular',
  '$http',
  'flashr',
  'WKD.Common.CurrentUser',
  '$state',
  function (Restangular, $http, flashr, currentUser, $state) {
    var vm = this;
    var baseRef = Restangular.all('users');

    if (!currentUser.hasRole('admin')) $state.go('wkd.dashboard');

    baseRef.getList().then(function (users) {
      vm.users = _.where(users, { attributes: { status: 'active' } });
      vm.pending = _.where(users, { attributes: { status: 'invitation-pending' } });
    });

    vm.inviteUser = function () {
      var data = angular.copy(vm.newUser);
      data.role = data.isAdmin ? 'admin' : 'user';
      delete data.isAdmin;

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

    vm.resendInvite = function (user) {
      return $http.post('/users/' + user.id + '/resend_invitation').then(function () {
        flashr.now.success(
          'Invitation email has been sent to ' + user.attributes.email
        );
      });
    };

    vm.deleteUser = function (user) {
      if (window.confirm('Are you sure?')) {
        return $http.delete('/users/' + user.id).then(function () {
          _.remove(vm.pending, user);
          flashr.now.success('User deleted');
        });
      }
    };
  }
])



;
