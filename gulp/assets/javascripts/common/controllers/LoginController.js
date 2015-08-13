'use strict';

angular.module('WKD.Common')

.controller('WKD.Common.LoginController', [
  '$rootScope',
  '$state',
  function ($rootScope, $state) {
    $rootScope.$$authenticated = false;

    var vm = this;

    vm.gotoDashboard = function () {
      var go = confirm('Doesnt actually do a login yet, pretend it works and goto dash?');

      if (go) {
        $rootScope.$$authenticated = true;
        $state.go('dashboard');
      }
    };
  }
]);