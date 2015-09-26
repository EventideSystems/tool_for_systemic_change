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
      vm.users = users;
    });

    vm.inviteUser = function () {
      $http.post('/users/invitation', { user: { email: vm.newEmail }})
        .then(function (resp) {
          flashr.now.success('An invitation email has been sent to ' + vm.newEmail);
        });
    };

  }
])



;
